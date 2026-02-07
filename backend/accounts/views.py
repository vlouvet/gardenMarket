from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

from gardens.models import GardenerProfile, Listing
from market.models import Order

from .models import Profile
from .serializers import ProfileSerializer, RegisterSerializer, UserSerializer


class RegisterView(generics.CreateAPIView):
    serializer_class = RegisterSerializer
    permission_classes = [permissions.AllowAny]


class MeView(APIView):
    def get(self, request):
        return Response(UserSerializer(request.user).data)


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = ProfileSerializer

    def get_object(self):
        return Profile.objects.get(user=self.request.user)


class UpgradeToGardenerView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        user = request.user
        if user.role != "CONSUMER":
            return Response({"detail": "Only consumers can upgrade"}, status=status.HTTP_400_BAD_REQUEST)
        has_purchase = Order.objects.filter(user=user, status=Order.Status.COMPLETE).exists()
        if not has_purchase:
            return Response(
                {"detail": "At least one completed purchase is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        user.role = "GARDENER"
        user.save(update_fields=["role"])
        GardenerProfile.objects.get_or_create(user=user)
        return Response(UserSerializer(user).data)


class OnboardingStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        profile = Profile.objects.filter(user=request.user).first()
        gardener = GardenerProfile.objects.filter(user=request.user).first()
        has_profile = bool(
            profile
            and profile.address_line1
            and profile.city
            and profile.state
            and profile.postal_code
        )
        has_payout = bool(gardener and gardener.payout_details)
        has_listing = Listing.objects.filter(plant__gardener__user=request.user).exists()
        return Response(
            {
                "profile_complete": has_profile,
                "payout_complete": has_payout,
                "first_listing": has_listing,
            }
        )
