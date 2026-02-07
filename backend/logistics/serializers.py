from rest_framework import serializers

from logistics.models import CenterSchedule, DistributionCenter


class DistributionCenterSerializer(serializers.ModelSerializer):
    remaining_capacity = serializers.SerializerMethodField()

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
            "capacity_per_day",
            "pickup_windows",
            "remaining_capacity",
        )
        read_only_fields = ("lat", "lon", "status")

    def get_remaining_capacity(self, obj: DistributionCenter):
        remaining_map = self.context.get("remaining_capacity_map", {})
        return remaining_map.get(obj.id)


class DistributionCenterAdminSerializer(serializers.ModelSerializer):
    class Meta:
        model = DistributionCenter
        fields = "__all__"


class CenterScheduleSerializer(serializers.ModelSerializer):
    class Meta:
        model = CenterSchedule
        fields = ("id", "center", "date", "capacity_override", "pickup_windows", "notes")
