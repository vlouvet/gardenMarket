from django.conf import settings
from django.core.management import call_command
from django.db import models
from django.db.models.signals import post_migrate, post_save
from django.dispatch import receiver

from gardens.models import GardenerProfile, Listing, Review


@receiver(post_save, sender=Review)
def update_gardener_rating(sender, instance: Review, **_kwargs):
    reviews = Review.objects.filter(gardener=instance.gardener)
    count = reviews.count()
    average = reviews.aggregate(avg_rating=models.Avg("rating"))
    rating_avg = average["avg_rating"] or 0
    GardenerProfile.objects.filter(id=instance.gardener_id).update(
        rating_avg=rating_avg, rating_count=count
    )


@receiver(post_migrate)
def auto_seed(sender, **_kwargs):
    if sender.name != "gardens":
        return
    if not getattr(settings, "SEED_ON_STARTUP", False):
        return
    if Listing.objects.exists():
        return
    call_command("seed_data")
