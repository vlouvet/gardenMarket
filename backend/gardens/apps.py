from django.apps import AppConfig


class GardensConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "gardens"

    def ready(self) -> None:
        from . import signals  # noqa: F401
