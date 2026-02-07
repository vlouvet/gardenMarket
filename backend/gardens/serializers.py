from rest_framework import serializers

from gardens.models import GardenerProfile, Listing, PlantProfile


class GardenerProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = GardenerProfile
        fields = ("id", "bio", "payout_details")


class PlantProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = PlantProfile
        fields = ("id", "gardener", "name", "species", "description", "tags")


class ListingSerializer(serializers.ModelSerializer):
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
            "created_at",
        )
