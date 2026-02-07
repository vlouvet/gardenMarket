import pytest
from rest_framework import status

from accounts.models import User
from market.models import Order


@pytest.mark.django_db
def test_register_role_mapping(api_client):
    response = api_client.post(
        "/api/accounts/register/",
        data={"email": "buyer1@example.com", "password": "pass1234", "role": "BUYER"},
        format="json",
    )
    assert response.status_code == status.HTTP_201_CREATED
    user = User.objects.get(email="buyer1@example.com")
    assert user.role == "CONSUMER"

    response = api_client.post(
        "/api/accounts/register/",
        data={"email": "grower1@example.com", "password": "pass1234", "role": "GROWER"},
        format="json",
    )
    assert response.status_code == status.HTTP_201_CREATED
    user = User.objects.get(email="grower1@example.com")
    assert user.role == "GARDENER"


@pytest.mark.django_db
def test_register_admin_disallowed(api_client):
    response = api_client.post(
        "/api/accounts/register/",
        data={"email": "admin@example.com", "password": "pass1234", "role": "ADMIN"},
        format="json",
    )
    assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
def test_upgrade_requires_completed_order(api_client, consumer_user):
    api_client.force_authenticate(user=consumer_user)
    response = api_client.post("/api/accounts/upgrade/", data={})
    assert response.status_code == status.HTTP_400_BAD_REQUEST

    Order.objects.create(user=consumer_user, status=Order.Status.COMPLETE)
    response = api_client.post("/api/accounts/upgrade/", data={})
    assert response.status_code == status.HTTP_200_OK
    consumer_user.refresh_from_db()
    assert consumer_user.role == "GARDENER"
