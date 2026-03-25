import random
from decimal import Decimal

from django.core.management.base import BaseCommand

from accounts.models import Profile, User
from gardens.models import GardenerProfile, Listing, PlantProfile
from logistics.models import DistributionCenter


PLANTS = [
    ("Basil", "Ocimum basilicum", "herb,culinary", "SOIL"),
    ("Tomato", "Solanum lycopersicum", "vegetable,summer", "SOIL"),
    ("Lettuce", "Lactuca sativa", "leafy,salad", "HYDROPONIC"),
    ("Strawberry", "Fragaria ananassa", "fruit,berry", "SOIL"),
    ("Mint", "Mentha spicata", "herb,tea", "SOIL"),
    ("Cilantro", "Coriandrum sativum", "herb,culinary", "SOIL"),
    ("Jalapeño", "Capsicum annuum", "pepper,spicy", "SOIL"),
    ("Kale", "Brassica oleracea", "leafy,superfood", "ORGANIC"),
    ("Cucumber", "Cucumis sativus", "vegetable,summer", "HYDROPONIC"),
    ("Bell Pepper", "Capsicum annuum", "pepper,sweet", "SOIL"),
    ("Rosemary", "Salvia rosmarinus", "herb,perennial", "SOIL"),
    ("Spinach", "Spinacia oleracea", "leafy,salad", "ORGANIC"),
    ("Lavender", "Lavandula angustifolia", "flower,aromatic", "SOIL"),
    ("Thyme", "Thymus vulgaris", "herb,culinary", "SOIL"),
    ("Zucchini", "Cucurbita pepo", "squash,summer", "SOIL"),
    ("Snap Pea", "Pisum sativum", "legume,climbing", "SOIL"),
    ("Swiss Chard", "Beta vulgaris", "leafy,colorful", "ORGANIC"),
    ("Arugula", "Eruca vesicaria", "leafy,peppery", "HYDROPONIC"),
    ("Oregano", "Origanum vulgare", "herb,culinary", "SOIL"),
    ("Chive", "Allium schoenoprasum", "herb,onion", "SOIL"),
]

GARDENERS = [
    ("gardener@example.com", "Alice Green", "Denver", "CO", "80202", 39.7392, -104.9903),
    ("grower2@example.com", "Bob Fields", "Boulder", "CO", "80302", 40.0150, -105.2705),
    ("grower3@example.com", "Carol Harvest", "Fort Collins", "CO", "80524", 40.5853, -105.0844),
]

CENTERS = [
    ("Denver Hub", "123 Main St", "Denver", "CO", "80202", 39.7392, -104.9903),
    ("Boulder Market", "456 Pearl St", "Boulder", "CO", "80302", 40.0150, -105.2705),
    ("Fort Collins Depot", "789 College Ave", "Fort Collins", "CO", "80524", 40.5853, -105.0844),
]

PICKUP_WINDOWS = ["Morning 8-11am", "Afternoon 12-3pm", "Evening 4-7pm"]
PICKUP_DAYS = [
    ["Monday", "Wednesday", "Friday"],
    ["Tuesday", "Thursday", "Saturday"],
    ["Saturday", "Sunday"],
    ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"],
]

SEED_NAMES = [
    "Heirloom Tomato", "Cherry Tomato", "Basil Genovese", "Thai Basil",
    "Lettuce Mix", "Butterhead Lettuce", "Romaine Lettuce", "Arugula",
    "Cilantro", "Dill", "Parsley", "Oregano", "Thyme", "Rosemary",
    "Mint", "Chive", "Sage", "Lavender", "Chamomile", "Echinacea",
    "Jalapeño", "Habanero", "Bell Pepper", "Banana Pepper", "Cayenne",
    "Cucumber", "Zucchini", "Yellow Squash", "Pumpkin", "Watermelon",
    "Cantaloupe", "Snap Pea", "Green Bean", "Lima Bean", "Black Bean",
    "Carrot", "Radish", "Beet", "Turnip", "Onion",
    "Garlic", "Leek", "Celery", "Fennel", "Kohlrabi",
    "Kale", "Collard Greens", "Swiss Chard", "Spinach", "Endive",
    "Sunflower", "Marigold", "Zinnia", "Cosmos", "Nasturtium",
    "Broccoli", "Cauliflower", "Brussels Sprout", "Cabbage", "Bok Choy",
    "Corn", "Okra", "Eggplant", "Artichoke", "Asparagus",
    "Strawberry Alpine", "Raspberry", "Blueberry", "Blackberry", "Gooseberry",
    "Lemongrass", "Stevia", "Borage", "Sorrel", "Lovage",
    "Microgreen Mix", "Sprouting Blend", "Wheatgrass", "Fenugreek", "Alfalfa",
    "Poblano Pepper", "Serrano Pepper", "Scotch Bonnet", "Ghost Pepper", "Thai Chili",
    "Roma Tomato", "Beefsteak Tomato", "Grape Tomato", "San Marzano", "Green Zebra",
    "Mesclun Mix", "Tatsoi", "Mizuna", "Pak Choi", "Mustard Greens",
]

PRODUCE_ITEMS = [
    "Fresh Basil Bunch", "Vine Tomatoes", "Mixed Lettuce", "Strawberry Pint",
    "Cucumber", "Jalapeño Bag", "Kale Bundle", "Bell Pepper Mix",
    "Zucchini", "Snap Peas",
]

CLIPPING_ITEMS = [
    "Rosemary Cutting", "Mint Runner", "Lavender Stem", "Thyme Sprig", "Sage Cutting",
]


class Command(BaseCommand):
    help = "Seed database with sample centers, gardeners, plants, and 115 listings"

    def add_arguments(self, parser):
        parser.add_argument(
            "--admin-email",
            help="Upgrade this user to GARDENER role with a gardener profile",
        )

    def handle(self, *args, **options):
        random.seed(42)

        # Centers
        created_centers = []
        for name, addr, city, state, zipcode, lat, lon in CENTERS:
            center, _ = DistributionCenter.objects.get_or_create(
                name=name,
                defaults=dict(
                    address_line1=addr, city=city, state=state,
                    postal_code=zipcode, country="US",
                    status=DistributionCenter.Status.APPROVED,
                    lat=lat, lon=lon,
                    capacity_per_day=100,
                    pickup_windows=PICKUP_WINDOWS,
                ),
            )
            created_centers.append(center)
            self.stdout.write(self.style.SUCCESS(f"Center: {center.name}"))

        # Gardeners
        gardener_profiles = []
        for email, name, city, state, zipcode, lat, lon in GARDENERS:
            user, _ = User.objects.get_or_create(
                email=email,
                defaults=dict(role=User.Role.GARDENER, username=email),
            )
            user.set_password("changeme")
            user.first_name = name.split()[0]
            user.last_name = name.split()[-1]
            user.save()

            profile, _ = Profile.objects.get_or_create(user=user)
            profile.address_line1 = f"123 {city} St"
            profile.city = city
            profile.state = state
            profile.postal_code = zipcode
            profile.country = "US"
            profile.lat = lat
            profile.lon = lon
            profile.save()

            gp, _ = GardenerProfile.objects.get_or_create(
                user=user,
                defaults=dict(bio=f"Local grower in {city}", verified=True),
            )
            gardener_profiles.append(gp)
            self.stdout.write(self.style.SUCCESS(f"Gardener: {email}"))

        # If --admin-email given, upgrade that user to gardener
        admin_email = options.get("admin_email")
        if admin_email:
            try:
                admin_user = User.objects.get(email=admin_email)
                admin_user.role = User.Role.GARDENER
                admin_user.save(update_fields=["role"])
                profile, _ = Profile.objects.get_or_create(user=admin_user)
                if not profile.lat:
                    profile.address_line1 = "123 Main St"
                    profile.city = "Denver"
                    profile.state = "CO"
                    profile.postal_code = "80202"
                    profile.country = "US"
                    profile.lat = 39.7392
                    profile.lon = -104.9903
                    profile.save()
                gp, _ = GardenerProfile.objects.get_or_create(
                    user=admin_user,
                    defaults=dict(bio="Admin grower", verified=True),
                )
                gardener_profiles.append(gp)
                self.stdout.write(self.style.SUCCESS(f"Upgraded {admin_email} to GARDENER"))
            except User.DoesNotExist:
                self.stdout.write(self.style.WARNING(f"User {admin_email} not found, skipping"))

        # Plants (assign round-robin to gardeners)
        plant_objects = []
        for i, (name, species, tags, method) in enumerate(PLANTS):
            gp = gardener_profiles[i % len(gardener_profiles)]
            plant, _ = PlantProfile.objects.get_or_create(
                gardener=gp, name=name,
                defaults=dict(
                    species=species, tags=tags,
                    grow_method=method,
                    description=f"Locally grown {name.lower()}",
                ),
            )
            plant_objects.append(plant)

        self.stdout.write(self.style.SUCCESS(f"Created {len(plant_objects)} plant profiles"))

        listing_count = 0

        # 100 Seed listings
        for i, seed_name in enumerate(SEED_NAMES[:100]):
            plant = plant_objects[i % len(plant_objects)]
            Listing.objects.get_or_create(
                plant=plant,
                type=Listing.ListingType.SEEDS,
                unit=random.choice([Listing.Unit.EACH, Listing.Unit.GRAM]),
                defaults=dict(
                    price=Decimal(str(round(random.uniform(2.50, 12.99), 2))),
                    quantity_available=random.randint(10, 200),
                    status=Listing.Status.ACTIVE,
                    pickup_window=random.choice(PICKUP_WINDOWS),
                    pickup_days=random.choice(PICKUP_DAYS),
                ),
            )
            listing_count += 1

        # 10 Produce listings
        for i, name in enumerate(PRODUCE_ITEMS):
            plant = plant_objects[i % len(plant_objects)]
            Listing.objects.get_or_create(
                plant=plant,
                type=Listing.ListingType.PRODUCE,
                unit=random.choice([Listing.Unit.LB, Listing.Unit.BUNDLE, Listing.Unit.EACH]),
                defaults=dict(
                    price=Decimal(str(round(random.uniform(3.00, 8.99), 2))),
                    quantity_available=random.randint(5, 50),
                    status=Listing.Status.ACTIVE,
                    pickup_window=random.choice(PICKUP_WINDOWS),
                    pickup_days=random.choice(PICKUP_DAYS),
                ),
            )
            listing_count += 1

        # 5 Clipping listings
        for i, name in enumerate(CLIPPING_ITEMS):
            plant = plant_objects[(i + 10) % len(plant_objects)]
            Listing.objects.get_or_create(
                plant=plant,
                type=Listing.ListingType.CLIPPING,
                unit=Listing.Unit.EACH,
                defaults=dict(
                    price=Decimal(str(round(random.uniform(1.50, 5.99), 2))),
                    quantity_available=random.randint(3, 30),
                    status=Listing.Status.ACTIVE,
                    pickup_window=random.choice(PICKUP_WINDOWS),
                    pickup_days=random.choice(PICKUP_DAYS),
                ),
            )
            listing_count += 1

        self.stdout.write(self.style.SUCCESS(f"Created {listing_count} listings (100 seeds, 10 produce, 5 clippings)"))
