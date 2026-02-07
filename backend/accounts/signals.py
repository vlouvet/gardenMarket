from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import Profile, User
from logistics.tasks import geocode_address_task


@receiver(post_save, sender=User)
def create_profile(sender, instance: User, created: bool, **_kwargs):
    if created:
        Profile.objects.get_or_create(user=instance)


@receiver(post_save, sender=Profile)
def enqueue_geocode(sender, instance: Profile, **_kwargs):
    if instance.address_line1 and instance.city and instance.state and instance.postal_code:
        geocode_address_task.delay(instance.user_id)
