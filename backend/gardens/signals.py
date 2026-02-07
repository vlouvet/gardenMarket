from django.db import models
from django.db.models.signals import post_save
from django.dispatch import receiver

from gardens.models import GardenerProfile, Review


@receiver(post_save, sender=Review)
def update_gardener_rating(sender, instance: Review, **_kwargs):
    reviews = Review.objects.filter(gardener=instance.gardener)
    count = reviews.count()
    average = reviews.aggregate(avg_rating=models.Avg("rating"))
    rating_avg = average["avg_rating"] or 0
    GardenerProfile.objects.filter(id=instance.gardener_id).update(
        rating_avg=rating_avg, rating_count=count
    )
