from django.urls import path

from rest_framework.routers import DefaultRouter

from logistics.views import (
    AdminCenterViewSet,
    CenterListView,
    CenterProposeView,
    CenterScheduleViewSet,
    center_review,
)

router = DefaultRouter()
router.register("schedules", CenterScheduleViewSet, basename="center-schedule")
router.register("admin", AdminCenterViewSet, basename="center-admin")

urlpatterns = [
    path("", CenterListView.as_view(), name="center-list"),
    path("propose/", CenterProposeView.as_view(), name="center-propose"),
    path("review/<int:pk>/", center_review, name="center-review"),
]

urlpatterns += router.urls
