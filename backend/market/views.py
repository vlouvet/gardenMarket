import uuid

from rest_framework import permissions, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from gardens.models import Listing
from logistics.services.eligibility import validate_order_eligibility
from market.models import Cart, CartItem, Order, OrderItem
from market.serializers import CartItemSerializer, CartSerializer, OrderSerializer


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

        order = Order.objects.create(
            user=request.user,
            distribution_center_id=center_id,
            pickup_window=request.data.get("pickup_window", ""),
            status=Order.Status.AWAITING_PICKUP_SCHEDULING,
        )
        for item in cart.items.select_related("listing"):
            OrderItem.objects.create(
                order=order,
                listing=item.listing,
                quantity=item.quantity,
                price_at_purchase=item.listing.price,
            )
        cart.items.all().delete()
        return Response(OrderSerializer(order).data, status=201)

    @action(detail=True, methods=["post"])
    def mock_pay(self, request, pk=None):
        order = self.get_object()
        order.status = Order.Status.SCHEDULED
        order.mock_payment_reference = uuid.uuid4().hex
        order.save(update_fields=["status", "mock_payment_reference"])
        return Response(OrderSerializer(order).data)
