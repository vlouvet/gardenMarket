import pytest

from accounts.models import User
from gardens.models import GardenerProfile
from sensors.models import SensorDevice


@pytest.mark.django_db
def test_sensor_device_owner():
    user = User.objects.create_user(email="g@example.com", password="pass", role="GARDENER")
    gardener = GardenerProfile.objects.create(user=user)
    device = SensorDevice.objects.create(gardener=gardener, name="Soil", type="moisture")
    assert device.gardener.user == user
