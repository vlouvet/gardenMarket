from django.contrib import admin

from mediahub.models import Photo, Post


@admin.register(Post)
class PostAdmin(admin.ModelAdmin):
    list_display = ("gardener", "created_at")


@admin.register(Photo)
class PhotoAdmin(admin.ModelAdmin):
    list_display = ("post", "created_at")
