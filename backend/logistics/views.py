from rest_framework import generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response

from accounts.models import User
from logistics.models import DistributionCenter
from logistics.serializers import DistributionCenterAdminSerializer, DistributionCenterSerializer
from logistics.services.geocode import geocode_address


class CenterListView(generics.ListAPIView):
    serializer_class = DistributionCenterSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        return DistributionCenter.objects.filter(status=DistributionCenter.Status.APPROVED)


class CenterProposeView(generics.CreateAPIView):
    serializer_class = DistributionCenterSerializer

    def perform_create(self, serializer):
        center = serializer.save(proposed_by=self.request.user)
        address = ", ".join(
            part
            for part in [
                center.address_line1,
                center.address_line2,
                center.city,
                center.state,
                center.postal_code,
                center.country,
            ]
            if part
        )
        result = geocode_address(address)
        if result:
            lat, lon, _confidence = result
            center.lat = lat
            center.lon = lon
            center.save(update_fields=["lat", "lon"])


@api_view(["POST"])
@permission_classes([permissions.IsAdminUser])
def center_review(request, pk: int):
    center = DistributionCenter.objects.get(pk=pk)
    status_value = request.data.get("status")
    if status_value not in DistributionCenter.Status.values:
        return Response({"detail": "Invalid status"}, status=400)
    center.status = status_value
    center.notes = request.data.get("notes", "")
    center.save(update_fields=["status", "notes"])
    return Response(DistributionCenterAdminSerializer(center).data)
