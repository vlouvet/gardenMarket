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

    def post(self, request):
        token = request.headers.get("X-Api-Token")
        if not token:
            return Response({"detail": "Missing token"}, status=status.HTTP_401_UNAUTHORIZED)
        device = SensorDevice.objects.filter(api_token=token).first()
        if not device:
            return Response({"detail": "Invalid token"}, status=status.HTTP_401_UNAUTHORIZED)
        serializer = SensorReadingSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(device=device)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
