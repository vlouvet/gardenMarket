from django.conf import settings
from django.db import models


class GardenerProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    bio = models.TextField(blank=True)
    payout_details = models.TextField(blank=True)
    verified = models.BooleanField(default=False)
    rating_avg = models.FloatField(default=0)
    rating_count = models.PositiveIntegerField(default=0)

    def __str__(self) -> str:
        return f"GardenerProfile({self.user_id})"


class PlantProfile(models.Model):
    class GrowMethod(models.TextChoices):
        SOIL = "SOIL", "Soil"
        HYDROPONIC = "HYDROPONIC", "Hydroponic"
        AQUAPONIC = "AQUAPONIC", "Aquaponic"
        ORGANIC = "ORGANIC", "Organic"

    gardener = models.ForeignKey(GardenerProfile, on_delete=models.CASCADE, related_name="plants")
    name = models.CharField(max_length=200)
    species = models.CharField(max_length=200, blank=True)
    description = models.TextField(blank=True)
    tags = models.CharField(max_length=255, blank=True)
    grow_method = models.CharField(
        max_length=20, choices=GrowMethod.choices, default=GrowMethod.SOIL
    )

    def __str__(self) -> str:
        return self.name


class Listing(models.Model):
    class ListingType(models.TextChoices):
        CLIPPING = "CLIPPING", "Clipping"
        SEEDS = "SEEDS", "Seeds"
        PRODUCE = "PRODUCE", "Produce"

    class Unit(models.TextChoices):
        EACH = "each", "Each"
        GRAM = "gram", "Gram"
        LB = "lb", "Pound"
        BUNDLE = "bundle", "Bundle"

    class Status(models.TextChoices):
        ACTIVE = "active", "Active"
        PAUSED = "paused", "Paused"
        SOLD_OUT = "sold_out", "Sold out"

    plant = models.ForeignKey(PlantProfile, on_delete=models.CASCADE, related_name="listings")
    type = models.CharField(max_length=20, choices=ListingType.choices)
    unit = models.CharField(max_length=20, choices=Unit.choices)
    price = models.DecimalField(max_digits=8, decimal_places=2)
    quantity_available = models.PositiveIntegerField(default=0)
    status = models.CharField(max_length=20, choices=Status.choices, default=Status.ACTIVE)
    is_hidden = models.BooleanField(default=False)
    pickup_window = models.CharField(max_length=100, blank=True)
    pickup_days = models.JSONField(default=list, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"Listing({self.plant_id})"


class Review(models.Model):
    gardener = models.ForeignKey(GardenerProfile, on_delete=models.CASCADE, related_name="reviews")
    reviewer = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    rating = models.PositiveSmallIntegerField()
    comment = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self) -> str:
        return f"Review({self.gardener_id}, {self.rating})"
