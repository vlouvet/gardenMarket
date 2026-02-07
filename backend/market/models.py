from django.conf import settings
from django.db import models

from gardens.models import Listing
from logistics.models import DistributionCenter


class Cart(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)


class CartItem(models.Model):
    cart = models.ForeignKey(Cart, on_delete=models.CASCADE, related_name="items")
    listing = models.ForeignKey(Listing, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField(default=1)


class Order(models.Model):
    class Status(models.TextChoices):
        CREATED = "CREATED", "Created"
        AWAITING_PICKUP_SCHEDULING = "AWAITING_PICKUP_SCHEDULING", "Awaiting pickup"
        SCHEDULED = "SCHEDULED", "Scheduled"
        COMPLETE = "COMPLETE", "Complete"
        CANCELLED = "CANCELLED", "Cancelled"

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    status = models.CharField(max_length=40, choices=Status.choices, default=Status.CREATED)
    distribution_center = models.ForeignKey(
        DistributionCenter, on_delete=models.PROTECT, null=True, blank=True
    )
    pickup_window = models.CharField(max_length=100, blank=True)
    pickup_date = models.DateField(null=True, blank=True)
    mock_payment_reference = models.CharField(max_length=100, blank=True)
    stripe_payment_intent_id = models.CharField(max_length=100, blank=True)
    payment_status = models.CharField(max_length=30, blank=True)
    checkin_code = models.CharField(max_length=64, blank=True)
    checked_in_at = models.DateTimeField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name="items")
    listing = models.ForeignKey(Listing, on_delete=models.PROTECT)
    quantity = models.PositiveIntegerField(default=1)
    price_at_purchase = models.DecimalField(max_digits=8, decimal_places=2)
