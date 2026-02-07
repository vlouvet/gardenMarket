from django.contrib import admin

from gardens.models import GardenerProfile, Listing, PlantProfile, Review


@admin.register(GardenerProfile)
class GardenerProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "bio", "verified", "rating_avg", "rating_count")


@admin.register(PlantProfile)
class PlantProfileAdmin(admin.ModelAdmin):
    list_display = ("name", "gardener")


@admin.register(Listing)
class ListingAdmin(admin.ModelAdmin):
    list_display = ("plant", "type", "unit", "price", "status")


@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ("gardener", "reviewer", "rating", "created_at")
