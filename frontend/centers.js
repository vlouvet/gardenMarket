const loadCenters = async () => {
  const container = document.getElementById("centers-list");
  if (!container) return;

  container.innerHTML = "<p>Loading centers...</p>";

  try {
    const centers = await request("/api/centers/");
    if (centers.length === 0) {
      container.innerHTML = "<p>No distribution centers available yet.</p>";
      return;
    }

    container.innerHTML = centers
      .map((c) => {
        const address = [c.address_line1, c.city, c.state, c.postal_code]
          .filter(Boolean)
          .join(", ");
        const statusClass = c.status === "ACTIVE" ? "" : " ghost";
        const windows = (c.pickup_windows || [])
          .map((w) => `<span class="pill ghost">${w}</span>`)
          .join("");
        const mapLink =
          c.lat && c.lon
            ? `<a class="button ghost" href="https://maps.google.com/?q=${c.lat},${c.lon}" target="_blank" rel="noopener">View on map</a>`
            : "";

        return `
          <article class="panel">
            <h3>${c.name}</h3>
            <p>${address}</p>
            <div class="badge-row">
              <span class="pill${statusClass}">${c.status || "Unknown"}</span>
            </div>
            <p class="capacity-line">Capacity: ${c.remaining_capacity ?? "?"} / ${c.capacity_per_day ?? "?"} per day</p>
            ${windows ? `<div class="badge-row">${windows}</div>` : ""}
            ${mapLink}
          </article>
        `;
      })
      .join("");
  } catch {
    container.innerHTML = "<p>Could not load distribution centers.</p>";
  }
};

document.addEventListener("DOMContentLoaded", loadCenters);
