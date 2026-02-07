from rest_framework.routers import DefaultRouter

from gardens.views import (
	AdminGardenerViewSet,
	AdminListingViewSet,
	GardenerProfileViewSet,
	ListingViewSet,
	PlantProfileViewSet,
	ReviewViewSet,
)

router = DefaultRouter()
router.register("gardeners", GardenerProfileViewSet, basename="gardener-profile")
router.register("plants", PlantProfileViewSet, basename="plant-profile")
router.register("listings", ListingViewSet, basename="listing")
router.register("reviews", ReviewViewSet, basename="review")
router.register("admin/gardeners", AdminGardenerViewSet, basename="admin-gardener")
router.register("admin/listings", AdminListingViewSet, basename="admin-listing")

urlpatterns = router.urls
