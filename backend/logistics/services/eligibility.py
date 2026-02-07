from typing import Iterable, List

from django.conf import settings

from logistics.models import DistributionCenter
from logistics.utils.distance import haversine_miles


def eligible_centers_for_location(lat: float, lon: float) -> List[DistributionCenter]:
    centers = DistributionCenter.objects.filter(status=DistributionCenter.Status.APPROVED)
    eligible = []
    for center in centers:
        if center.lat is None or center.lon is None:
            continue
        if haversine_miles(lat, lon, center.lat, center.lon) <= settings.LOGISTICS_MAX_DISTANCE_MILES:
            eligible.append(center)
    return eligible


def intersect_centers(*centers: Iterable[DistributionCenter]) -> List[DistributionCenter]:
    sets = [set(center_list) for center_list in centers]
    if not sets:
        return []
    intersection = set.intersection(*sets)
    return list(intersection)


def validate_order_eligibility(consumer, gardener_users) -> List[DistributionCenter]:
    if not consumer.profile.lat or not consumer.profile.lon:
        return []
    consumer_centers = eligible_centers_for_location(consumer.profile.lat, consumer.profile.lon)

    gardener_centers = []
    for gardener in gardener_users:
        if not gardener.profile.lat or not gardener.profile.lon:
            return []
        gardener_centers.append(
            eligible_centers_for_location(gardener.profile.lat, gardener.profile.lon)
        )

    return intersect_centers(consumer_centers, *gardener_centers)
