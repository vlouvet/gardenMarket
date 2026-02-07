from rest_framework import serializers

from gardens.models import GardenerProfile, Listing, PlantProfile, Review


class GardenerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = GardenerProfile
        fields = ("id", "bio", "payout_details", "verified", "rating_avg", "rating_count")


class PlantProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlantProfile
        fields = (
            "id",
            "gardener",
            "name",
            "species",
            "description",
            "tags",
            "grow_method",
        )


class ListingSerializer(serializers.ModelSerializer):
    in_stock = serializers.SerializerMethodField()
    distance_miles = serializers.SerializerMethodField()
    grown_within_miles = serializers.SerializerMethodField()
    grower_verified = serializers.SerializerMethodField()
    grower_rating = serializers.SerializerMethodField()

    class Meta:
        model = Listing
        fields = (
            "id",
            "plant",
            "type",
            "unit",
            "price",
            "quantity_available",
            "status",
            "is_hidden",
            "pickup_window",
            "pickup_days",
            "created_at",
            "in_stock",
            "distance_miles",
            "grown_within_miles",
            "grower_verified",
            "grower_rating",
        )

    def get_in_stock(self, obj: Listing) -> bool:
        return obj.quantity_available > 0

    def get_distance_miles(self, obj: Listing):
        distances = self.context.get("distance_map", {})
        return distances.get(obj.id)

    def get_grown_within_miles(self, obj: Listing):
        miles = self.get_distance_miles(obj)
        if miles is None:
            return None
        return round(miles)

    def get_grower_verified(self, obj: Listing) -> bool:
        return obj.plant.gardener.verified

    def get_grower_rating(self, obj: Listing):
        return obj.plant.gardener.rating_avg


class ReviewSerializer(serializers.ModelSerializer):
    class Meta:
        model = Review
        fields = ("id", "gardener", "reviewer", "rating", "comment", "created_at")
        read_only_fields = ("reviewer", "created_at")
