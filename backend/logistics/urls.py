from django.urls import path

from logistics.views import CenterListView, CenterProposeView, center_review

urlpatterns = [
    path("", CenterListView.as_view(), name="center-list"),
    path("propose/", CenterProposeView.as_view(), name="center-propose"),
    path("review/<int:pk>/", center_review, name="center-review"),
]
