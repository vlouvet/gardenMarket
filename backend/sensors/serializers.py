from rest_framework import serializers

from sensors.models import SensorDevice, SensorReading


class SensorDeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = SensorDevice
        fields = ("id", "gardener", "name", "type", "location_tag", "api_token")
        read_only_fields = ("api_token",)


class SensorReadingSerializer(serializers.ModelSerializer):
    class Meta:
        model = SensorReading
        fields = ("id", "device", "timestamp", "metric", "value", "unit")
