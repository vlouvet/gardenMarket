import base64

from django.core.files.base import ContentFile
from django.core.management.base import BaseCommand

from accounts.models import Profile, User
from gardens.models import GardenerProfile, Listing, PlantProfile
from logistics.models import DistributionCenter
from mediahub.models import Photo, Post


SAMPLE_PNG = base64.b64decode(
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAA"
    "AAC0lEQVR42mP8/5+hHgAFgwJ/l+0sWQAAAABJRU5ErkJggg=="
)


class Command(BaseCommand):
    help = "Create sample centers, gardeners, plants, listings, posts, and photos"

    def handle(self, *args, **options):
        center, _created = DistributionCenter.objects.get_or_create(
            name="Denver Hub",
            address_line1="123 Main St",
            city="Denver",
            state="CO",
            postal_code="80202",
            country="US",
            status=DistributionCenter.Status.APPROVED,
            lat=39.7392,
            lon=-104.9903,
        )
        self.stdout.write(self.style.SUCCESS(f"Center: {center.name}"))

        user, _created = User.objects.get_or_create(
            email="gardener@example.com", role=User.Role.GARDENER
        )
        user.set_password("changeme")
        user.save()
        profile, _created = Profile.objects.get_or_create(user=user)
        profile.address_line1 = "123 Main St"
        profile.city = "Denver"
        profile.state = "CO"
        profile.postal_code = "80202"
        profile.country = "US"
        profile.lat = 39.7392
        profile.lon = -104.9903
        profile.save()

        gardener, _created = GardenerProfile.objects.get_or_create(user=user)
        plant, _created = PlantProfile.objects.get_or_create(
            gardener=gardener,
            name="Basil",
            species="Ocimum basilicum",
            description="Fresh basil",
            tags="herb,sun",
        )
        listing, _created = Listing.objects.get_or_create(
            plant=plant,
            type=Listing.ListingType.PRODUCE,
            unit=Listing.Unit.BUNDLE,
            price=4.50,
            quantity_available=25,
        )
        self.stdout.write(self.style.SUCCESS(f"Listing: {listing.id}"))

        post, _created = Post.objects.get_or_create(gardener=gardener, text="First harvest")
        photo = Photo.objects.create(post=post)
        photo.image.save("sample.png", ContentFile(SAMPLE_PNG))
        self.stdout.write(self.style.SUCCESS("Sample post and photo created"))
