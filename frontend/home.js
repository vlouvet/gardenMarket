const loadMetrics = async () => {
  const listingsEl = document.getElementById("metric-listings");
  const centersEl = document.getElementById("metric-centers");
  if (!listingsEl || !centersEl) return;

  try {
    const [listings, centers] = await Promise.all([
      request("/api/listings/"),
      request("/api/centers/"),
    ]);
    listingsEl.textContent = listings.length;
    centersEl.textContent = centers.length;
  } catch {
    // keep static fallback values on error
  }
};

document.addEventListener("DOMContentLoaded", loadMetrics);
