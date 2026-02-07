from django.contrib import admin

from moderation.models import Report


@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ("reporter", "listing", "reported_user", "created_at")
