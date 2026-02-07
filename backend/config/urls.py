from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

from config.views import health_check

urlpatterns = [
    path("admin/", admin.site.urls),
    path("health/", health_check, name="health"),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="docs"),
    path("api/accounts/", include("accounts.urls")),
    path("api/centers/", include("logistics.urls")),
    path("api/", include("gardens.urls")),
    path("api/", include("mediahub.urls")),
    path("api/", include("market.urls")),
    path("api/", include("sensors.urls")),
    path("api/", include("moderation.urls")),
]
