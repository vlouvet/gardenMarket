let myPlants = [];
let myListings = [];

const initDashboard = async () => {
  if (!requireAuth()) return;

  const status = document.getElementById("dashboard-status");
  const profileEl = document.getElementById("grower-profile");
  const listingsTable = document.getElementById("listings-table");
  const ordersEl = document.getElementById("gardener-orders");
  const plantSelect = document.getElementById("plant-select");
  const createForm = document.getElementById("create-listing-form");
  const listingMsg = document.getElementById("listing-message");
  const saveBtn = document.getElementById("save-listings-btn");
  const saveMsg = document.getElementById("listings-save-message");

  // Check role
  try {
    const me = await request("/api/accounts/me/");
    if (me.role !== "GROWER") {
      if (status) status.textContent = "You need grower access. Visit Grow With Us to upgrade.";
      document.getElementById("grower-profile-section")?.remove();
      document.getElementById("create-listing-section")?.remove();
      return;
    }
  } catch (error) {
    if (status) status.textContent = error.message;
    return;
  }

  // Load grower data in parallel
  try {
    const [gardeners, plants, listings, orders] = await Promise.all([
      request("/api/gardeners/").catch(() => []),
      request("/api/plants/"),
      request("/api/listings/"),
      request("/api/orders/gardener/").catch(() => []),
    ]);

    // Grower profile
    const profile = Array.isArray(gardeners) ? gardeners[0] : gardeners;
    if (profile && profileEl) {
      profileEl.innerHTML = `
        <p>Bio: ${profile.bio || "Not set"}</p>
        <p>Verified: ${profile.verified ? "Yes" : "No"} &middot; Rating: ${profile.rating_avg ?? "--"} (${profile.rating_count ?? 0} reviews)</p>
      `;
    }

    // Plant select
    myPlants = Array.isArray(plants) ? plants : [];
    if (plantSelect) {
      plantSelect.innerHTML =
        '<option value="">Select a plant</option>' +
        myPlants.map((p) => `<option value="${p.id}">${p.name} (${p.species || ""})</option>`).join("");
    }

    // Filter listings to this grower's plants
    const myPlantIds = new Set(myPlants.map((p) => p.id));
    myListings = (Array.isArray(listings) ? listings : []).filter((l) => myPlantIds.has(l.plant));

    if (listingsTable) {
      if (myListings.length === 0) {
        listingsTable.innerHTML = "<p>No listings yet. Create one above.</p>";
      } else {
        listingsTable.innerHTML = `
          <div class="listings-grid">
            ${myListings
              .map(
                (l) => `
              <div class="listing-row" data-id="${l.id}">
                <strong>${myPlants.find((p) => p.id === l.plant)?.name || `Plant #${l.plant}`}</strong>
                <label>Price <input type="number" step="0.01" name="price" value="${l.price}" /></label>
                <label>Qty <input type="number" name="quantity_available" value="${l.quantity_available}" /></label>
                <label>Status
                  <select name="status">
                    <option value="ACTIVE"${l.status === "ACTIVE" ? " selected" : ""}>Active</option>
                    <option value="PAUSED"${l.status === "PAUSED" ? " selected" : ""}>Paused</option>
                  </select>
                </label>
              </div>
            `
              )
              .join("")}
          </div>
        `;
        if (saveBtn) saveBtn.style.display = "";
      }
    }

    // Gardener orders
    if (ordersEl) {
      if (orders.length === 0) {
        ordersEl.innerHTML = "<p>No orders for your items yet.</p>";
      } else {
        ordersEl.innerHTML = orders
          .map(
            (o) => `
            <div class="order-card panel">
              <h3>Order #${o.id}</h3>
              <span class="pill">${o.status}</span>
              <p>Pickup: ${o.pickup_date || "--"} &middot; ${o.pickup_window || "--"}</p>
              <ul>${(o.items || []).map((i) => `<li>Listing #${i.listing} &times; ${i.quantity}</li>`).join("")}</ul>
            </div>
          `
          )
          .join("");
      }
    }
  } catch (error) {
    if (status) status.textContent = error.message;
  }

  // Create listing
  if (createForm) {
    createForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      const data = Object.fromEntries(new FormData(createForm).entries());
      data.plant = Number(data.plant);
      data.price = data.price;
      data.quantity_available = Number(data.quantity_available);

      try {
        await request("/api/listings/", {
          method: "POST",
          body: JSON.stringify(data),
        });
        setMessage(listingMsg, "Listing created!");
        createForm.reset();
        initDashboard();
      } catch (error) {
        setMessage(listingMsg, error.message);
      }
    });
  }

  // Save listing changes (batch update)
  if (saveBtn) {
    saveBtn.addEventListener("click", async () => {
      const rows = document.querySelectorAll(".listing-row");
      const updates = [];
      rows.forEach((row) => {
        updates.push({
          id: Number(row.dataset.id),
          price: row.querySelector('[name="price"]').value,
          quantity_available: Number(row.querySelector('[name="quantity_available"]').value),
          status: row.querySelector('[name="status"]').value,
        });
      });

      try {
        await request("/api/listings/batch_update/", {
          method: "POST",
          body: JSON.stringify({ updates }),
        });
        setMessage(saveMsg, "Listings updated.");
      } catch (error) {
        setMessage(saveMsg, error.message);
      }
    });
  }
};

document.addEventListener("DOMContentLoaded", initDashboard);
