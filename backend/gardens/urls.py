from rest_framework.routers import DefaultRouter

from gardens.views import GardenerProfileViewSet, ListingViewSet, PlantProfileViewSet

router = DefaultRouter()
router.register("gardeners", GardenerProfileViewSet, basename="gardener-profile")
router.register("plants", PlantProfileViewSet, basename="plant-profile")
router.register("listings", ListingViewSet, basename="listing")

urlpatterns = router.urls
