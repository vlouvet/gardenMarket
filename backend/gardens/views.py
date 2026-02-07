from typing import Optional

from django.db.models import Q
from rest_framework import permissions, viewsets
from rest_framework.response import Response

from accounts.models import Profile, User
from gardens.models import GardenerProfile, Listing, PlantProfile
from gardens.permissions import IsGardener
from gardens.serializers import GardenerProfileSerializer, ListingSerializer, PlantProfileSerializer
from django.conf import settings

from logistics.services.eligibility import eligible_centers_for_location
from logistics.services.geocode import geocode_address
from logistics.utils.distance import haversine_miles


class GardenerProfileViewSet(viewsets.ModelViewSet):
    serializer_class = GardenerProfileSerializer
    permission_classes = [permissions.IsAuthenticated, IsGardener]

    def get_queryset(self):
        return GardenerProfile.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class PlantProfileViewSet(viewsets.ModelViewSet):
    serializer_class = PlantProfileSerializer
    permission_classes = [permissions.IsAuthenticated, IsGardener]

    def get_queryset(self):
        return PlantProfile.objects.filter(gardener__user=self.request.user)


class ListingViewSet(viewsets.ModelViewSet):
    serializer_class = ListingSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    def get_queryset(self):
        queryset = Listing.objects.select_related("plant", "plant__gardener").all()
        address = self.request.query_params.get("address")
        lat = self.request.query_params.get("lat")
        lon = self.request.query_params.get("lon")
        if address or (lat and lon):
            location = self._resolve_location(address, lat, lon)
            if location:
                eligible_centers = eligible_centers_for_location(location[0], location[1])
                gardener_ids = self._eligible_gardener_user_ids(eligible_centers)
                queryset = queryset.filter(plant__gardener__user_id__in=gardener_ids)
        return queryset

    def _resolve_location(self, address: Optional[str], lat: Optional[str], lon: Optional[str]):
        if lat and lon:
            return float(lat), float(lon)
        if address:
            result = geocode_address(address)
            if result:
                return result[0], result[1]
        return None

    def _eligible_gardener_user_ids(self, centers):
        eligible_users = []
        for profile in Profile.objects.exclude(lat__isnull=True).exclude(lon__isnull=True):
            for center in centers:
                if center.lat is None or center.lon is None:
                    continue
                if (
                    haversine_miles(profile.lat, profile.lon, center.lat, center.lon)
                    <= settings.LOGISTICS_MAX_DISTANCE_MILES
                ):
                    eligible_users.append(profile.user_id)
                    break
        return eligible_users

    def get_permissions(self):
        if self.action in ["create", "update", "partial_update", "destroy"]:
            return [permissions.IsAuthenticated(), IsGardener()]
        return super().get_permissions()
