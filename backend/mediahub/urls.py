from rest_framework.routers import DefaultRouter

from mediahub.views import PhotoViewSet, PostViewSet

router = DefaultRouter()
router.register("posts", PostViewSet, basename="post")
router.register("photos", PhotoViewSet, basename="photo")

urlpatterns = router.urls
