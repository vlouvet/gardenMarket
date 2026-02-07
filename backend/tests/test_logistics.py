import math

import pytest

from logistics.models import DistributionCenter
from logistics.services.eligibility import eligible_centers_for_location, intersect_centers
from logistics.utils.distance import haversine_miles


@pytest.mark.django_db
def test_haversine_distance():
    denver = (39.7392, -104.9903)
    boulder = (40.01499, -105.2705)
    distance = haversine_miles(denver[0], denver[1], boulder[0], boulder[1])
    assert math.isclose(distance, 24, rel_tol=0.3)


@pytest.mark.django_db
def test_eligible_centers_for_location(approved_center):
    centers = eligible_centers_for_location(39.7392, -104.9903)
    assert approved_center in centers


@pytest.mark.django_db
def test_intersect_centers(approved_center):
    other = DistributionCenter.objects.create(
        name="North Hub",
        address_line1="2 Center",
        city="Denver",
        state="CO",
        postal_code="80202",
        country="US",
        status=DistributionCenter.Status.APPROVED,
        lat=39.75,
        lon=-104.98,
    )
    intersection = intersect_centers([approved_center, other], [approved_center])
    assert intersection == [approved_center]
