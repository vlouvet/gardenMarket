from celery import shared_task

from accounts.models import Profile
from logistics.services.geocode import geocode_address


@shared_task
def geocode_address_task(user_id: int) -> bool:
    profile = Profile.objects.filter(user_id=user_id).first()
    if not profile:
        return False

    address = ", ".join(
        part
        for part in [
            profile.address_line1,
            profile.address_line2,
            profile.city,
            profile.state,
            profile.postal_code,
            profile.country,
        ]
        if part
    )
    if not address:
        return False

    result = geocode_address(address)
    if not result:
        return False

    lat, lon, confidence = result
    profile.lat = lat
    profile.lon = lon
    profile.geocode_confidence = confidence
    profile.save(update_fields=["lat", "lon", "geocode_confidence"])
    return True
