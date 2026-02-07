import secrets

from django.db import models

from gardens.models import GardenerProfile


def _generate_token() -> str:
    return secrets.token_hex(16)


class SensorDevice(models.Model):
    gardener = models.ForeignKey(GardenerProfile, on_delete=models.CASCADE, related_name="devices")
    name = models.CharField(max_length=200)
    type = models.CharField(max_length=100)
    location_tag = models.CharField(max_length=100, blank=True)
    api_token = models.CharField(max_length=64, default=_generate_token, unique=True)

    def rotate_token(self):
        self.api_token = _generate_token()
        self.save(update_fields=["api_token"])


class SensorReading(models.Model):
    device = models.ForeignKey(SensorDevice, on_delete=models.CASCADE, related_name="readings")
    timestamp = models.DateTimeField()
    metric = models.CharField(max_length=100)
    value = models.FloatField()
    unit = models.CharField(max_length=50)
