import pytest
from rest_framework import status

from gardens.models import GardenerProfile, Review


@pytest.mark.django_db
def test_review_updates_rating(api_client, consumer_user, gardener_user):
    gardener = GardenerProfile.objects.get(user=gardener_user)
    api_client.force_authenticate(user=consumer_user)

    response = api_client.post(
        "/api/reviews/",
        data={"gardener": gardener.id, "rating": 5, "comment": "Great"},
        format="json",
    )
    assert response.status_code == status.HTTP_201_CREATED
    gardener.refresh_from_db()
    assert gardener.rating_count == 1
    assert gardener.rating_avg == 5
    assert Review.objects.filter(gardener=gardener).exists()
