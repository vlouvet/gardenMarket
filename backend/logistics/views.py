from datetime import date as date_cls

from rest_framework import generics, permissions, viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response

from accounts.models import User
from logistics.models import CenterSchedule, DistributionCenter
from logistics.serializers import (
    CenterScheduleSerializer,
    DistributionCenterAdminSerializer,
    DistributionCenterSerializer,
)
from logistics.services.geocode import geocode_address
from logistics.utils.distance import haversine_miles
from market.models import Order


class CenterListView(generics.ListAPIView):
    serializer_class = DistributionCenterSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = DistributionCenter.objects.filter(status=DistributionCenter.Status.APPROVED)
        near = self.request.query_params.get("near")
        date_value = self.request.query_params.get("date")
        if near:
            result = geocode_address(near)
            if result:
                lat, lon, _confidence = result
                queryset = [
                    center
                    for center in queryset
                    if center.lat is not None
                    and center.lon is not None
                    and haversine_miles(lat, lon, center.lat, center.lon) <= 100
                ]
        if date_value:
            remaining_map = {}
            try:
                target_date = date_cls.fromisoformat(date_value)
            except ValueError:
                target_date = None
            if target_date:
                for center in queryset:
                    schedule = CenterSchedule.objects.filter(center=center, date=target_date).first()
                    capacity = schedule.capacity_override if schedule and schedule.capacity_override else center.capacity_per_day
                    used = Order.objects.filter(
                        distribution_center=center, pickup_date=target_date
                    ).count()
                    remaining_map[center.id] = max(capacity - used, 0)
            self.serializer_class = DistributionCenterSerializer
            self._remaining_map = remaining_map
        return queryset

    def get_serializer_context(self):
        context = super().get_serializer_context()
        if hasattr(self, "_remaining_map"):
            context["remaining_capacity_map"] = self._remaining_map
        return context


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


class CenterScheduleViewSet(viewsets.ModelViewSet):
    serializer_class = CenterScheduleSerializer
    permission_classes = [permissions.IsAdminUser]

    def get_queryset(self):
        queryset = CenterSchedule.objects.select_related("center").all()
        center_id = self.request.query_params.get("center")
        if center_id:
            queryset = queryset.filter(center_id=center_id)
        return queryset


class AdminCenterViewSet(viewsets.ModelViewSet):
    serializer_class = DistributionCenterAdminSerializer
    permission_classes = [permissions.IsAdminUser]

    def get_queryset(self):
        return DistributionCenter.objects.all()


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
