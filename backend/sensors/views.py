from datetime import timedelta

from django.conf import settings
from django.core.cache import cache
from django.utils import timezone
from rest_framework import permissions, status, viewsets
from rest_framework.response import Response
from rest_framework.views import APIView

from gardens.permissions import IsGardener
from sensors.models import SensorDevice, SensorReading
from sensors.permissions import IsOwnerGardener
from sensors.serializers import SensorDeviceSerializer, SensorReadingSerializer


class SensorDeviceViewSet(viewsets.ModelViewSet):
    serializer_class = SensorDeviceSerializer
    permission_classes = [permissions.IsAuthenticated, IsGardener, IsOwnerGardener]

    def get_queryset(self):
        return SensorDevice.objects.filter(gardener__user=self.request.user)


class SensorReadingViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = SensorReadingSerializer
    permission_classes = [permissions.IsAuthenticated, IsGardener]

    def get_queryset(self):
        return SensorReading.objects.filter(device__gardener__user=self.request.user)


class SensorIngestView(APIView):
    permission_classes = [permissions.AllowAny]

    def _rate_limit_exceeded(self, token: str) -> bool:
        limit = getattr(settings, "SENSORS_INGEST_RATE_LIMIT_PER_MIN", 60)
        key = f"sensors:ingest:{token}"
        if cache.add(key, 1, timeout=60):
            return False
        try:
            count = cache.incr(key)
        except ValueError:
            cache.set(key, 1, timeout=60)
            return False
        return count > limit

    def post(self, request):
        token = request.headers.get("X-Api-Token")
        if not token:
            return Response({"detail": "Missing token"}, status=status.HTTP_401_UNAUTHORIZED)
        device = SensorDevice.objects.filter(api_token=token).first()
        if not device:
            return Response({"detail": "Invalid token"}, status=status.HTTP_401_UNAUTHORIZED)
        if self._rate_limit_exceeded(token):
            return Response({"detail": "Rate limit exceeded"}, status=status.HTTP_429_TOO_MANY_REQUESTS)
        serializer = SensorReadingSerializer(data=request.data)
        if serializer.is_valid():
            timestamp = serializer.validated_data["timestamp"]
            if timestamp > timezone.now() + timedelta(minutes=5):
                return Response(
                    {"detail": "Timestamp is too far in the future"},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            serializer.save(device=device)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
