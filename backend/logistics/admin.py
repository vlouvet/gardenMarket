from django.contrib import admin

from logistics.models import DistributionCenter, GeocodeCache


@admin.register(DistributionCenter)
class DistributionCenterAdmin(admin.ModelAdmin):
    list_display = ("name", "city", "state", "status")
    list_filter = ("status",)


@admin.register(GeocodeCache)
class GeocodeCacheAdmin(admin.ModelAdmin):
    list_display = ("normalized_address", "provider", "created_at")
