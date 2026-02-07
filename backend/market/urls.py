from rest_framework.routers import DefaultRouter
from django.urls import path

from market.views import CartViewSet, OrderViewSet, StripeWebhookView

router = DefaultRouter()
router.register("cart", CartViewSet, basename="cart")
router.register("orders", OrderViewSet, basename="orders")

urlpatterns = router.urls
urlpatterns += [
	path("payments/stripe/webhook/", StripeWebhookView.as_view(), name="stripe-webhook"),
]
