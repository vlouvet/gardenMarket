import math

import pytest

from logistics.utils.distance import haversine_miles


@pytest.mark.django_db
def test_haversine_distance():
    denver = (39.7392, -104.9903)
    boulder = (40.01499, -105.2705)
    distance = haversine_miles(denver[0], denver[1], boulder[0], boulder[1])
    assert math.isclose(distance, 24, rel_tol=0.3)
