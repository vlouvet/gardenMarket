from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import MeView, OnboardingStatusView, ProfileView, RegisterView, UpgradeToGardenerView

urlpatterns = [
    path("register/", RegisterView.as_view(), name="register"),
    path("login/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("me/", MeView.as_view(), name="me"),
    path("profile/", ProfileView.as_view(), name="profile"),
    path("upgrade/", UpgradeToGardenerView.as_view(), name="upgrade-to-gardener"),
    path("onboarding/", OnboardingStatusView.as_view(), name="onboarding"),
]
