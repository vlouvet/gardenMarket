from django.conf import settings
from django.db import models


class GeocodeCache(models.Model):
    address_hash = models.CharField(max_length=64, unique=True)
    normalized_address = models.TextField()
    lat = models.FloatField()
    lon = models.FloatField()
    confidence = models.CharField(max_length=20, blank=True)
    provider = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"GeocodeCache({self.address_hash})"


class DistributionCenter(models.Model):
    class Status(models.TextChoices):
        PROPOSED = "PROPOSED", "Proposed"
        APPROVED = "APPROVED", "Approved"
        REJECTED = "REJECTED", "Rejected"
        INACTIVE = "INACTIVE", "Inactive"

    name = models.CharField(max_length=200)
    address_line1 = models.CharField(max_length=255)
    address_line2 = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=100)
    state = models.CharField(max_length=100)
    postal_code = models.CharField(max_length=20)
    country = models.CharField(max_length=2, default="US")
    lat = models.FloatField(null=True, blank=True)
    lon = models.FloatField(null=True, blank=True)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.PROPOSED)
    proposed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, null=True, blank=True, on_delete=models.SET_NULL
    )
    notes = models.TextField(blank=True)
    capacity_per_day = models.PositiveIntegerField(default=50)
    pickup_windows = models.JSONField(default=list, blank=True)

    def __str__(self) -> str:
        return self.name


class CenterSchedule(models.Model):
    center = models.ForeignKey(DistributionCenter, on_delete=models.CASCADE, related_name="schedules")
    date = models.DateField()
    capacity_override = models.PositiveIntegerField(null=True, blank=True)
    pickup_windows = models.JSONField(default=list, blank=True)
    notes = models.TextField(blank=True)

    class Meta:
        unique_together = ("center", "date")

    def __str__(self) -> str:
        return f"{self.center.name} {self.date}"
