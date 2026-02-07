from django.contrib import admin

from gardens.models import GardenerProfile, Listing, PlantProfile


@admin.register(GardenerProfile)
class GardenerProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "bio")


@admin.register(PlantProfile)
class PlantProfileAdmin(admin.ModelAdmin):
    list_display = ("name", "gardener")


@admin.register(Listing)
class ListingAdmin(admin.ModelAdmin):
    list_display = ("plant", "type", "unit", "price", "status")
