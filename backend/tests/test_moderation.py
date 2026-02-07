import pytest
from rest_framework import status

from gardens.models import Listing


@pytest.mark.django_db
def test_report_create(api_client, consumer_user, plant_profile):
    listing = Listing.objects.create(
        plant=plant_profile,
        type="PRODUCE",
        unit="lb",
        price=4.50,
        quantity_available=5,
    )
    api_client.force_authenticate(user=consumer_user)
    response = api_client.post(
        "/api/reports/", data={"listing": listing.id, "reason": "Spam"}, format="json"
    )
    assert response.status_code == status.HTTP_201_CREATED
