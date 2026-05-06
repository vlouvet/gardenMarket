from rest_framework import serializers

from market.models import Cart, CartItem, Order, OrderItem


class CartItemSerializer(serializers.ModelSerializer):
    plant_name = serializers.CharField(source="listing.plant.name", read_only=True)
    listing_type = serializers.CharField(source="listing.type", read_only=True)
    listing_unit = serializers.CharField(source="listing.unit", read_only=True)
    listing_price = serializers.DecimalField(
        source="listing.price", max_digits=10, decimal_places=2, read_only=True,
    )

    class Meta:
        model = CartItem
        fields = (
            "id",
            "listing",
            "plant_name",
            "listing_type",
            "listing_unit",
            "listing_price",
            "quantity",
        )


class CartSerializer(serializers.ModelSerializer):
    items = CartItemSerializer(many=True, read_only=True)

    class Meta:
        model = Cart
        fields = ("id", "items")


class OrderItemSerializer(serializers.ModelSerializer):
    plant_name = serializers.CharField(source="listing.plant.name", read_only=True)
    listing_type = serializers.CharField(source="listing.type", read_only=True)
    listing_unit = serializers.CharField(source="listing.unit", read_only=True)

    class Meta:
        model = OrderItem
        fields = (
            "id",
            "listing",
            "plant_name",
            "listing_type",
            "listing_unit",
            "quantity",
            "price_at_purchase",
        )


class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)

    class Meta:
        model = Order
        fields = (
            "id",
            "status",
            "distribution_center",
            "pickup_window",
            "pickup_date",
            "mock_payment_reference",
            "stripe_payment_intent_id",
            "payment_status",
            "checkin_code",
            "checked_in_at",
            "created_at",
            "items",
        )
        read_only_fields = (
            "mock_payment_reference",
            "stripe_payment_intent_id",
            "payment_status",
            "checkin_code",
            "checked_in_at",
            "created_at",
        )
