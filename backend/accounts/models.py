from django.contrib.auth.models import AbstractUser, UserManager
from django.db import models


class CustomUserManager(UserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Email is required")
        email = self.normalize_email(email)
        extra_fields.setdefault("username", email)
        return super().create_user(username=email, email=email, password=password, **extra_fields)

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        return self.create_user(email, password, **extra_fields)


class User(AbstractUser):
    class Role(models.TextChoices):
        GARDENER = "GARDENER", "Gardener"
        CONSUMER = "CONSUMER", "Consumer"
        ADMIN = "ADMIN", "Admin"

    username = models.CharField(max_length=150, blank=True, null=True)
    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=Role.choices, default=Role.CONSUMER)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS = []

    objects = CustomUserManager()

    def save(self, *args, **kwargs):
        if not self.username:
            self.username = self.email
        super().save(*args, **kwargs)


class Profile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    address_line1 = models.CharField(max_length=255, blank=True)
    address_line2 = models.CharField(max_length=255, blank=True)
    city = models.CharField(max_length=100, blank=True)
    state = models.CharField(max_length=100, blank=True)
    postal_code = models.CharField(max_length=20, blank=True)
    country = models.CharField(max_length=2, blank=True)
    lat = models.FloatField(null=True, blank=True)
    lon = models.FloatField(null=True, blank=True)
    geocoded_at = models.DateTimeField(null=True, blank=True)
    geocode_confidence = models.CharField(max_length=20, blank=True)

    def __str__(self) -> str:
        return f"Profile({self.user_id})"
