import pytest
from django.test import override_settings
from django.utils import timezone
from rest_framework import status

from gardens.models import GardenerProfile
from sensors.models import SensorDevice, SensorReading


@pytest.mark.django_db
def test_sensor_device_owner(gardener_user):
    gardener = GardenerProfile.objects.get(user=gardener_user)
    device = SensorDevice.objects.create(gardener=gardener, name="Soil", type="moisture")
    assert device.gardener.user == gardener_user


@pytest.mark.django_db
def test_sensor_ingest_requires_token(api_client):
    response = api_client.post("/api/sensors/ingest/", data={})
    assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
def test_sensor_ingest_valid_token(api_client, gardener_user):
    gardener = GardenerProfile.objects.get(user=gardener_user)
    device = SensorDevice.objects.create(gardener=gardener, name="Soil", type="moisture")
    payload = {
        "timestamp": timezone.now().isoformat(),
        "metric": "humidity",
        "value": 42.2,
        "unit": "%",
    }
    response = api_client.post(
        "/api/sensors/ingest/",
        data=payload,
        format="json",
        HTTP_X_API_TOKEN=device.api_token,
    )
    assert response.status_code == status.HTTP_201_CREATED
    assert SensorReading.objects.filter(device=device).exists()


@pytest.mark.django_db
def test_sensor_privacy(api_client, gardener_user):
    other_user = gardener_user.__class__.objects.create_user(
        email="other@example.com", password="pass1234", role="GARDENER"
    )
    GardenerProfile.objects.get_or_create(user=other_user)
    device = SensorDevice.objects.create(
        gardener=GardenerProfile.objects.get(user=gardener_user),
        name="Temp",
        type="temp",
    )

    api_client.force_authenticate(user=other_user)
    response = api_client.get(f"/api/sensors/{device.id}/")
    assert response.status_code == status.HTTP_404_NOT_FOUND


@pytest.mark.django_db
@override_settings(SENSORS_INGEST_RATE_LIMIT_PER_MIN=1)
def test_sensor_ingest_rate_limit(api_client, gardener_user):
    gardener = GardenerProfile.objects.get(user=gardener_user)
    device = SensorDevice.objects.create(gardener=gardener, name="Soil", type="moisture")
    payload = {
        "timestamp": timezone.now().isoformat(),
        "metric": "humidity",
        "value": 42.2,
        "unit": "%",
    }
    response = api_client.post(
        "/api/sensors/ingest/",
        data=payload,
        format="json",
        HTTP_X_API_TOKEN=device.api_token,
    )
    assert response.status_code == status.HTTP_201_CREATED
    response = api_client.post(
        "/api/sensors/ingest/",
        data=payload,
        format="json",
        HTTP_X_API_TOKEN=device.api_token,
    )
    assert response.status_code == status.HTTP_429_TOO_MANY_REQUESTS
