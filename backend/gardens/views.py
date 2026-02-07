from typing import Optional

from django.db.models import Q
from rest_framework import permissions, viewsets
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from rest_framework.decorators import action

from accounts.models import Profile, User
from gardens.models import GardenerProfile, Listing, PlantProfile, Review
from gardens.permissions import IsGardener
from gardens.serializers import (
    GardenerProfileSerializer,
    ListingSerializer,
    PlantProfileSerializer,
    ReviewSerializer,
)
from django.conf import settings

from logistics.services.eligibility import eligible_centers_for_location
from logistics.services.geocode import geocode_address
from logistics.utils.distance import haversine_miles
from moderation.services import log_admin_action


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
        listing_type = self.request.query_params.get("type")
        grow_method = self.request.query_params.get("grow_method")
        pickup_day = self.request.query_params.get("pickup_day")
        in_stock = self.request.query_params.get("in_stock")

        if listing_type:
            queryset = queryset.filter(type=listing_type)
        if grow_method:
            queryset = queryset.filter(plant__grow_method=grow_method)
        if pickup_day:
            queryset = queryset.filter(pickup_days__contains=[pickup_day])
        if in_stock == "1":
            queryset = queryset.filter(quantity_available__gt=0)

        if not (self.request.user and self.request.user.is_staff):
            queryset = queryset.filter(is_hidden=False)
        self._location = None
        if address or (lat and lon):
            self._location = self._resolve_location(address, lat, lon)
            if self._location:
                eligible_centers = eligible_centers_for_location(self._location[0], self._location[1])
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
        for profile in (
            Profile.objects.filter(user__role="GARDENER")
            .exclude(lat__isnull=True)
            .exclude(lon__isnull=True)
        ):
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

    def perform_create(self, serializer):
        profile = Profile.objects.filter(user=self.request.user).first()
        if not profile or profile.lat is None or profile.lon is None:
            raise ValidationError("Gardener must have a geocoded location")
        centers = eligible_centers_for_location(profile.lat, profile.lon)
        if not centers:
            raise ValidationError("Gardener is not within 100 miles of an approved center")
        serializer.save()

    def get_serializer_context(self):
        context = super().get_serializer_context()
        if getattr(self, "_location", None):
            distance_map = {}
            for listing in context["view"].get_queryset():
                profile = listing.plant.gardener.user.profile
                if profile.lat is None or profile.lon is None:
                    continue
                distance = haversine_miles(
                    self._location[0], self._location[1], profile.lat, profile.lon
                )
                distance_map[listing.id] = distance
            context["distance_map"] = distance_map
        return context

    @action(detail=False, methods=["post"], permission_classes=[permissions.IsAuthenticated, IsGardener])
    def batch_update(self, request):
        updates = request.data.get("updates", [])
        updated = []
        for payload in updates:
            listing_id = payload.get("id")
            if not listing_id:
                continue
            listing = Listing.objects.filter(
                id=listing_id, plant__gardener__user=request.user
            ).first()
            if not listing:
                continue
            for field in ["price", "quantity_available", "pickup_window", "pickup_days"]:
                if field in payload:
                    setattr(listing, field, payload[field])
            if "status" in payload:
                listing.status = payload["status"]
            listing.save()
            updated.append(listing.id)
        return Response({"updated": updated})


class ReviewViewSet(viewsets.ModelViewSet):
    serializer_class = ReviewSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        gardener_id = self.request.query_params.get("gardener")
        queryset = Review.objects.select_related("gardener", "reviewer").all()
        if gardener_id:
            queryset = queryset.filter(gardener_id=gardener_id)
        return queryset

    def perform_create(self, serializer):
        serializer.save(reviewer=self.request.user)


class AdminGardenerViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = GardenerProfileSerializer
    permission_classes = [permissions.IsAdminUser]

    def get_queryset(self):
        return GardenerProfile.objects.select_related("user").all()

    @action(detail=True, methods=["post"], permission_classes=[permissions.IsAdminUser])
    def verify(self, request, pk=None):
        gardener = self.get_object()
        gardener.verified = True
        gardener.save(update_fields=["verified"])
        log_admin_action(request.user, "verify_gardener", "gardener", gardener.id)
        return Response(GardenerProfileSerializer(gardener).data)


class AdminListingViewSet(viewsets.ReadOnlyModelViewSet):
    serializer_class = ListingSerializer
    permission_classes = [permissions.IsAdminUser]

    def get_queryset(self):
        return Listing.objects.select_related("plant", "plant__gardener").all()

    @action(detail=True, methods=["post"], permission_classes=[permissions.IsAdminUser])
    def hide(self, request, pk=None):
        listing = self.get_object()
        listing.is_hidden = True
        listing.save(update_fields=["is_hidden"])
        return Response(ListingSerializer(listing).data)

    @action(detail=True, methods=["post"], permission_classes=[permissions.IsAdminUser])
    def show(self, request, pk=None):
        listing = self.get_object()
        listing.is_hidden = False
        listing.save(update_fields=["is_hidden"])
        return Response(ListingSerializer(listing).data)

    @action(detail=True, methods=["post"], permission_classes=[permissions.IsAdminUser])
    def pause(self, request, pk=None):
        listing = self.get_object()
        listing.status = Listing.Status.PAUSED
        listing.save(update_fields=["status"])
        return Response(ListingSerializer(listing).data)

    @action(detail=True, methods=["post"], permission_classes=[permissions.IsAdminUser])
    def unpause(self, request, pk=None):
        listing = self.get_object()
        listing.status = Listing.Status.ACTIVE
        listing.save(update_fields=["status"])
        return Response(ListingSerializer(listing).data)
