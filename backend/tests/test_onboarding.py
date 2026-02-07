import pytest
from rest_framework import status

from accounts.models import Profile
from gardens.models import GardenerProfile, Listing, PlantProfile


@pytest.mark.django_db
def test_onboarding_status(api_client, gardener_user):
    api_client.force_authenticate(user=gardener_user)
    response = api_client.get("/api/accounts/onboarding/")
    assert response.status_code == status.HTTP_200_OK
    assert response.data["profile_complete"] is False

    profile = Profile.objects.get(user=gardener_user)
    profile.address_line1 = "123 Main"
    profile.city = "Denver"
    profile.state = "CO"
    profile.postal_code = "80202"
    profile.save()

    gardener = GardenerProfile.objects.get(user=gardener_user)
    gardener.payout_details = "test"
    gardener.save()

    plant = PlantProfile.objects.create(gardener=gardener, name="Basil")
    Listing.objects.create(plant=plant, type="PRODUCE", unit="lb", price=4.5, quantity_available=2)

    response = api_client.get("/api/accounts/onboarding/")
    assert response.data["profile_complete"] is True
    assert response.data["payout_complete"] is True
    assert response.data["first_listing"] is True
