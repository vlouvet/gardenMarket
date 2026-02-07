from rest_framework import serializers

from mediahub.models import Photo, Post


class PostSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ("id", "gardener", "plant", "text", "created_at")


class PhotoSerializer(serializers.ModelSerializer):
    class Meta:
        model = Photo
        fields = ("id", "post", "image", "created_at")
