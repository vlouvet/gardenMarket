import csv
import uuid
from datetime import date as date_cls

from django.conf import settings
from django.db import transaction
from django.http import HttpResponse
from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView

from gardens.models import Listing
from gardens.permissions import IsGardener
from logistics.services.eligibility import validate_order_eligibility
from market.models import Cart, CartItem, Order, OrderItem
from market.serializers import CartItemSerializer, CartSerializer, OrderSerializer
from market.services.notifications import send_order_notification
from market.services.payments import create_payment_intent, construct_webhook_event, create_refund
from moderation.services import log_admin_action


class CartViewSet(viewsets.ViewSet):
    permission_classes = [permissions.IsAuthenticated]

    def list(self, request):
        cart, _created = Cart.objects.get_or_create(user=request.user)
        return Response(CartSerializer(cart).data)

    def create(self, request):
        cart, _created = Cart.objects.get_or_create(user=request.user)
        serializer = CartItemSerializer(data=request.data)
        if serializer.is_valid():
            CartItem.objects.create(cart=cart, **serializer.validated_data)
            return Response(CartSerializer(cart).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, pk=None):
        cart, _created = Cart.objects.get_or_create(user=request.user)
        CartItem.objects.filter(cart=cart, pk=pk).delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


class OrderViewSet(viewsets.ModelViewSet):
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Order.objects.filter(user=self.request.user)

    def create(self, request, *args, **kwargs):
        cart, _created = Cart.objects.get_or_create(user=request.user)
        if not cart.items.exists():
            return Response({"detail": "Cart is empty"}, status=status.HTTP_400_BAD_REQUEST)

        gardener_users = {
            item.listing.plant.gardener.user for item in cart.items.select_related("listing__plant__gardener")
        }
        centers = validate_order_eligibility(request.user, gardener_users)
        if not centers:
            return Response({"detail": "No eligible distribution centers"}, status=400)

        center_id = request.data.get("distribution_center")
        if not center_id or int(center_id) not in {center.id for center in centers}:
            return Response({"detail": "Invalid distribution center"}, status=400)

        pickup_date = request.data.get("pickup_date")
        if pickup_date:
            try:
                pickup_date = date_cls.fromisoformat(pickup_date)
            except ValueError:
                return Response({"detail": "Invalid pickup_date"}, status=400)
        pickup_window = request.data.get("pickup_window", "")

        items = list(cart.items.select_related("listing"))
        for item in items:
            if item.listing.quantity_available < item.quantity:
                return Response(
                    {"detail": "Insufficient inventory"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        with transaction.atomic():
            order = Order.objects.create(
                user=request.user,
                distribution_center_id=center_id,
                pickup_window=pickup_window,
                pickup_date=pickup_date,
                status=Order.Status.AWAITING_PICKUP_SCHEDULING,
                payment_status="pending",
                checkin_code=uuid.uuid4().hex,
            )
            for item in items:
                OrderItem.objects.create(
                    order=order,
                    listing=item.listing,
                    quantity=item.quantity,
                    price_at_purchase=item.listing.price,
                )
                item.listing.quantity_available -= item.quantity
                if item.listing.quantity_available <= settings.LISTING_LOW_STOCK_THRESHOLD:
                    item.listing.status = "paused"
                item.listing.save(update_fields=["quantity_available", "status"])
            cart.items.all().delete()

        send_order_notification(
            request.user.email,
            "Order created",
            f"Order #{order.id} is created. Pickup window: {pickup_window}",
        )
        return Response(OrderSerializer(order).data, status=201)

    @action(detail=True, methods=["post"])
    def mock_pay(self, request, pk=None):
        order = self.get_object()
        order.status = Order.Status.SCHEDULED
        order.mock_payment_reference = uuid.uuid4().hex
        order.payment_status = "paid"
        order.save(update_fields=["status", "mock_payment_reference", "payment_status"])
        send_order_notification(
            order.user.email,
            "Order payment received",
            f"Order #{order.id} payment received.",
        )
        return Response(OrderSerializer(order).data)

    @action(detail=True, methods=["post"])
    def payment_intent(self, request, pk=None):
        order = self.get_object()
        amount = sum(item.quantity * item.price_at_purchase for item in order.items.all())
        tax_amount = amount * settings.TAX_RATE
        amount_cents = int((amount + tax_amount) * 100)
        intent = create_payment_intent(
            amount_cents,
            settings.STRIPE_CURRENCY,
            {"order_id": str(order.id), "user_id": str(order.user_id)},
        )
        order.stripe_payment_intent_id = intent.id
        order.payment_status = intent.status
        order.save(update_fields=["stripe_payment_intent_id", "payment_status"])
        return Response({"client_secret": intent.client_secret})

    @action(detail=False, methods=["get"], permission_classes=[permissions.IsAdminUser])
    def pick_pack(self, request):
        orders = Order.objects.filter(status=Order.Status.SCHEDULED).prefetch_related("items__listing")
        payload = []
        for order in orders:
            payload.append(
                {
                    "order_id": order.id,
                    "center": order.distribution_center_id,
                    "pickup_date": order.pickup_date,
                    "items": [
                        {
                            "listing": item.listing_id,
                            "quantity": item.quantity,
                            "unit": item.listing.unit,
                        }
                        for item in order.items.all()
                    ],
                }
            )
        return Response(payload)

    @action(detail=False, methods=["get"], permission_classes=[permissions.IsAdminUser])
    def export_csv(self, request):
        response = HttpResponse(content_type="text/csv")
        response["Content-Disposition"] = "attachment; filename=orders.csv"
        writer = csv.writer(response)
        writer.writerow(["order_id", "user_id", "status", "center_id", "pickup_date", "pickup_window"])
        for order in Order.objects.all():
            writer.writerow(
                [
                    order.id,
                    order.user_id,
                    order.status,
                    order.distribution_center_id,
                    order.pickup_date,
                    order.pickup_window,
                ]
            )
        return response

    @action(detail=True, methods=["post"], permission_classes=[permissions.IsAdminUser])
    def checkin(self, request, pk=None):
        order = self.get_object()
        code = request.data.get("checkin_code")
        if code and code != order.checkin_code:
            return Response({"detail": "Invalid check-in code"}, status=status.HTTP_400_BAD_REQUEST)
        order.checked_in_at = timezone.now()
        order.save(update_fields=["checked_in_at"])
        log_admin_action(request.user, "order_checkin", "order", order.id)
        return Response(OrderSerializer(order).data)

    @action(detail=True, methods=["post"], permission_classes=[permissions.IsAdminUser])
    def refund(self, request, pk=None):
        order = self.get_object()
        if not order.stripe_payment_intent_id:
            return Response({"detail": "No Stripe payment intent"}, status=400)
        refund = create_refund(order.stripe_payment_intent_id)
        order.payment_status = "refunded"
        order.status = Order.Status.CANCELLED
        order.save(update_fields=["payment_status", "status"])
        log_admin_action(request.user, "order_refund", "order", order.id)
        return Response({"refund_id": refund.id})

    @action(detail=False, methods=["get"], permission_classes=[permissions.IsAuthenticated, IsGardener])
    def gardener(self, request):
        orders = Order.objects.filter(items__listing__plant__gardener__user=request.user).distinct()
        return Response(OrderSerializer(orders, many=True).data)


class StripeWebhookView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        payload = request.body
        sig_header = request.headers.get("Stripe-Signature", "")
        try:
            event = construct_webhook_event(payload, sig_header)
        except Exception:
            return Response(status=status.HTTP_400_BAD_REQUEST)

        if event["type"] == "payment_intent.succeeded":
            intent = event["data"]["object"]
            order = Order.objects.filter(stripe_payment_intent_id=intent["id"]).first()
            if order:
                order.payment_status = "succeeded"
                order.status = Order.Status.SCHEDULED
                order.save(update_fields=["payment_status", "status"])
                send_order_notification(
                    order.user.email,
                    "Order payment received",
                    f"Order #{order.id} payment received.",
                )
        return Response(status=status.HTTP_200_OK)
