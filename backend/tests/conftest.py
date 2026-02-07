import pytest
from rest_framework.test import APIClient

from accounts.models import Profile, User
from gardens.models import GardenerProfile, PlantProfile
from logistics.models import DistributionCenter


@pytest.fixture(autouse=True)
def disable_geocode_delay(monkeypatch):
    from logistics import tasks

    monkeypatch.setattr(tasks.geocode_address_task, "delay", lambda *_args, **_kwargs: None)


@pytest.fixture
def api_client():
    return APIClient()


@pytest.fixture
def consumer_user():
    user = User.objects.create_user(email="buyer@example.com", password="pass1234", role="CONSUMER")
    Profile.objects.get_or_create(user=user)
    return user


@pytest.fixture
def gardener_user():
    user = User.objects.create_user(email="grower@example.com", password="pass1234", role="GARDENER")
    Profile.objects.get_or_create(user=user)
    GardenerProfile.objects.get_or_create(user=user)
    return user


@pytest.fixture
def admin_user():
    user = User.objects.create_user(email="admin@example.com", password="pass1234", role="ADMIN")
    user.is_staff = True
    user.is_superuser = True
    user.save()
    return user


@pytest.fixture
def approved_center():
    return DistributionCenter.objects.create(
        name="Central Hub",
        address_line1="1 Center",
        city="Denver",
        state="CO",
        postal_code="80202",
        country="US",
        status=DistributionCenter.Status.APPROVED,
        lat=39.7392,
        lon=-104.9903,
    )


@pytest.fixture
def plant_profile(gardener_user):
    gardener = GardenerProfile.objects.get(user=gardener_user)
    return PlantProfile.objects.create(gardener=gardener, name="Basil", species="Ocimum")
