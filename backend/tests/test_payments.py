import pytest
from rest_framework import status

from accounts.models import Profile
from gardens.models import Listing
from market.models import Order, OrderItem


class DummyIntent:
    def __init__(self):
        self.id = "pi_test"
        self.client_secret = "secret"
        self.status = "requires_payment_method"


@pytest.mark.django_db
def test_payment_intent_creation(api_client, consumer_user, gardener_user, plant_profile, approved_center, monkeypatch):
    consumer_profile = Profile.objects.get(user=consumer_user)
    consumer_profile.lat = approved_center.lat
    consumer_profile.lon = approved_center.lon
    consumer_profile.save(update_fields=["lat", "lon"])

    gardener_profile = Profile.objects.get(user=gardener_user)
    gardener_profile.lat = approved_center.lat
    gardener_profile.lon = approved_center.lon
    gardener_profile.save(update_fields=["lat", "lon"])

    listing = Listing.objects.create(
        plant=plant_profile,
        type="PRODUCE",
        unit="lb",
        price=4.50,
        quantity_available=5,
    )

    order = Order.objects.create(
        user=consumer_user,
        distribution_center=approved_center,
        pickup_window="Tomorrow",
        status=Order.Status.AWAITING_PICKUP_SCHEDULING,
    )
    OrderItem.objects.create(order=order, listing=listing, quantity=1, price_at_purchase=listing.price)

    from market import views as market_views

    monkeypatch.setattr(market_views, "create_payment_intent", lambda *_args, **_kwargs: DummyIntent())

    api_client.force_authenticate(user=consumer_user)
    response = api_client.post(f"/api/orders/{order.id}/payment_intent/")
    assert response.status_code == status.HTTP_200_OK
    order.refresh_from_db()
    assert order.stripe_payment_intent_id == "pi_test"
