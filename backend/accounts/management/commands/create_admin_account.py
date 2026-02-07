from django.contrib.auth import get_user_model
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    help = "Create an admin account with role ADMIN"

    def add_arguments(self, parser):
        parser.add_argument("email")
        parser.add_argument("password")

    def handle(self, *args, **options):
        email = options["email"]
        password = options["password"]
        User = get_user_model()
        user, created = User.objects.get_or_create(email=email, defaults={"role": "ADMIN"})
        if not created:
            user.role = "ADMIN"
        user.set_password(password)
        user.is_staff = True
        user.is_superuser = True
        user.save()
        self.stdout.write(self.style.SUCCESS(f"Admin account ready: {email}"))
