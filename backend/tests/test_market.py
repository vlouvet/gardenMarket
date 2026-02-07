import pytest
from rest_framework import status

from accounts.models import Profile
from gardens.models import Listing
from market.models import Order


@pytest.mark.django_db
def test_order_creation_flow(
    api_client, consumer_user, gardener_user, plant_profile, approved_center
):
    consumer_profile = Profile.objects.get(user=consumer_user)
    consumer_profile.lat = approved_center.lat
    consumer_profile.lon = approved_center.lon
    consumer_profile.save(update_fields=["lat", "lon"])

    gardener_profile = Profile.objects.get(user=gardener_user)
    gardener_profile.lat = approved_center.lat
    gardener_profile.lon = approved_center.lon
    gardener_profile.save(update_fields=["lat", "lon"])

    listing = Listing.objects.create(
        plant=plant_profile,
        type="PRODUCE",
        unit="lb",
        price=4.50,
        quantity_available=5,
    )

    api_client.force_authenticate(user=consumer_user)
    response = api_client.post(
        "/api/cart/", data={"listing": listing.id, "quantity": 2}, format="json"
    )
    assert response.status_code == status.HTTP_201_CREATED

    response = api_client.post(
        "/api/orders/",
        data={"distribution_center": approved_center.id, "pickup_window": "Tomorrow"},
        format="json",
    )
    assert response.status_code == status.HTTP_201_CREATED
    order_id = response.data["id"]

    response = api_client.post(f"/api/orders/{order_id}/mock_pay/")
    assert response.status_code == status.HTTP_200_OK
    assert Order.objects.get(id=order_id).status == Order.Status.SCHEDULED
