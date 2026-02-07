from django.contrib.auth import get_user_model
from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from .models import Profile

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ("email", "password", "role")

    def validate_role(self, value: str) -> str:
        if not value:
            raise ValidationError("Role is required")
        role = value.upper()
        role_map = {
            "GROWER": "GARDENER",
            "GARDENER": "GARDENER",
            "BUYER": "CONSUMER",
            "CONSUMER": "CONSUMER",
            "ADMIN": "ADMIN",
        }
        if role not in role_map:
            raise ValidationError("Invalid role")
        if role_map[role] == "ADMIN":
            raise ValidationError("Admin self-registration is disabled")
        return role_map[role]

    def create(self, validated_data):
        password = validated_data.pop("password")
        user = User(**validated_data)
        user.set_password(password)
        user.save()
        Profile.objects.get_or_create(user=user)
        return user


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ("id", "email", "role")


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = Profile
        fields = (
            "address_line1",
            "address_line2",
            "city",
            "state",
            "postal_code",
            "country",
            "lat",
            "lon",
            "geocoded_at",
            "geocode_confidence",
        )
        read_only_fields = ("lat", "lon", "geocoded_at", "geocode_confidence")
