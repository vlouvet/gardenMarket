from django.urls import path

from moderation.views import ReportCreateView, ReportListView

urlpatterns = [
    path("reports/", ReportCreateView.as_view(), name="report-create"),
    path("admin/reports/", ReportListView.as_view(), name="report-list"),
]
