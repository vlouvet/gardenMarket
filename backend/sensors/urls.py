from rest_framework.routers import DefaultRouter
from django.urls import path

from sensors.views import SensorDeviceViewSet, SensorIngestView, SensorReadingViewSet

router = DefaultRouter()
router.register("sensors", SensorDeviceViewSet, basename="sensor-device")
router.register("readings", SensorReadingViewSet, basename="sensor-reading")

urlpatterns = [
    path("sensors/ingest/", SensorIngestView.as_view(), name="sensor-ingest"),
]
urlpatterns += router.urls
