import hashlib
import time
from typing import Optional, Tuple

import requests
from django.conf import settings

from logistics.models import GeocodeCache


def _normalize_address(address: str) -> str:
    return " ".join(address.lower().split())


def _address_hash(address: str) -> str:
    return hashlib.sha256(address.encode("utf-8")).hexdigest()


def geocode_address(address: str) -> Optional[Tuple[float, float, str]]:
    normalized = _normalize_address(address)
    address_hash = _address_hash(normalized)
    cached = GeocodeCache.objects.filter(address_hash=address_hash).first()
    if cached:
        return cached.lat, cached.lon, cached.confidence

    if settings.LOGISTICS_GEO_PROVIDER != "nominatim":
        raise ValueError("Only nominatim is configured for Phase 1")

    url = "https://nominatim.openstreetmap.org/search"
    params = {"q": normalized, "format": "json", "limit": 1}
    headers = {"User-Agent": "gardenMarket/0.1"}

    for attempt in range(3):
        response = requests.get(url, params=params, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            if data:
                lat = float(data[0]["lat"])
                lon = float(data[0]["lon"])
                confidence = data[0].get("type", "")
                GeocodeCache.objects.create(
                    address_hash=address_hash,
                    normalized_address=normalized,
                    lat=lat,
                    lon=lon,
                    confidence=confidence,
                    provider=settings.LOGISTICS_GEO_PROVIDER,
                )
                return lat, lon, confidence
        time.sleep(2**attempt)

    return None
