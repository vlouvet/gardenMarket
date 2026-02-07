from django.contrib import admin

from logistics.models import CenterSchedule, DistributionCenter, GeocodeCache


@admin.register(DistributionCenter)
class DistributionCenterAdmin(admin.ModelAdmin):
    list_display = ("name", "city", "state", "status", "capacity_per_day")
    list_filter = ("status",)


@admin.register(GeocodeCache)
class GeocodeCacheAdmin(admin.ModelAdmin):
    list_display = ("normalized_address", "provider", "created_at")


@admin.register(CenterSchedule)
class CenterScheduleAdmin(admin.ModelAdmin):
    list_display = ("center", "date", "capacity_override")
