import pytest
from rest_framework import status

from accounts.models import Profile
from gardens.models import Listing


@pytest.mark.django_db
def test_listing_requires_geocode(api_client, gardener_user, plant_profile):
    api_client.force_authenticate(user=gardener_user)
    payload = {
        "plant": plant_profile.id,
        "type": "PRODUCE",
        "unit": "lb",
        "price": "4.50",
        "quantity_available": 5,
    }
    response = api_client.post("/api/listings/", data=payload, format="json")
    assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
def test_listing_create_with_eligible_center(
    api_client, gardener_user, plant_profile, approved_center
):
    profile = Profile.objects.get(user=gardener_user)
    profile.lat = approved_center.lat
    profile.lon = approved_center.lon
    profile.save(update_fields=["lat", "lon"])

    api_client.force_authenticate(user=gardener_user)
    payload = {
        "plant": plant_profile.id,
        "type": "PRODUCE",
        "unit": "lb",
        "price": "4.50",
        "quantity_available": 5,
    }
    response = api_client.post("/api/listings/", data=payload, format="json")
    assert response.status_code == status.HTTP_201_CREATED
    assert Listing.objects.filter(plant=plant_profile).exists()
