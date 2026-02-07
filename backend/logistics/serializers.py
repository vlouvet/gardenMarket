from rest_framework import serializers

from logistics.models import DistributionCenter


class DistributionCenterSerializer(serializers.ModelSerializer):
    class Meta:
        model = DistributionCenter
        fields = (
            "id",
            "name",
            "address_line1",
            "address_line2",
            "city",
            "state",
            "postal_code",
            "country",
            "lat",
            "lon",
            "status",
        )
        read_only_fields = ("lat", "lon", "status")


class DistributionCenterAdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = DistributionCenter
        fields = "__all__"
