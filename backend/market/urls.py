from rest_framework.routers import DefaultRouter

from market.views import CartViewSet, OrderViewSet

router = DefaultRouter()
router.register("cart", CartViewSet, basename="cart")
router.register("orders", OrderViewSet, basename="orders")

urlpatterns = router.urls
