from django.db import models

from gardens.models import GardenerProfile, PlantProfile


class Post(models.Model):
    gardener = models.ForeignKey(GardenerProfile, on_delete=models.CASCADE, related_name="posts")
    plant = models.ForeignKey(PlantProfile, on_delete=models.SET_NULL, null=True, blank=True)
    text = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)


class Photo(models.Model):
    post = models.ForeignKey(Post, on_delete=models.CASCADE, related_name="photos")
    image = models.ImageField(upload_to="posts/")
    created_at = models.DateTimeField(auto_now_add=True)
