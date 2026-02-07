from rest_framework import serializers

from moderation.models import Report


class ReportSerializer(serializers.ModelSerializer):
    class Meta:
        model = Report
        fields = ("id", "listing", "reported_user", "reason", "created_at")
        read_only_fields = ("created_at",)
