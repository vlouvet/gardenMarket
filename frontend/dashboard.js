import { request, requireAuth, showLoading, hideLoading, showError, setMessage } from "./app.js";

let myPlants = [];
let myListings = [];
let myGardenerProfileId = null;

const initDashboard = async () => {
  if (!requireAuth()) return;

  const status = document.getElementById("dashboard-status");
  const profileEl = document.getElementById("grower-profile");
  const listingsTable = document.getElementById("listings-table");
  const ordersEl = document.getElementById("gardener-orders");
  const plantSelect = document.getElementById("plant-select");
  const createForm = document.getElementById("create-listing-form");
  const listingMsg = document.getElementById("listing-message");
  const createPlantForm = document.getElementById("create-plant-form");
  const plantMsg = document.getElementById("plant-message");
  const saveBtn = document.getElementById("save-listings-btn");
  const saveMsg = document.getElementById("listings-save-message");

  if (status) showLoading(status);

  // Check role
  try {
    const me = await request("/api/accounts/me/");
    if (status) hideLoading(status);
    if (me.role !== "GARDENER") {
      if (status) status.textContent = "You need gardener access. Visit Grow With Us to upgrade.";
      document.getElementById("grower-profile-section")?.remove();
      document.getElementById("create-listing-section")?.remove();
      return;
    }
  } catch (error) {
    if (status) {
      hideLoading(status);
      showError(status, error.message);
    }
    return;
  }

  // Load grower data in parallel
  if (listingsTable) showLoading(listingsTable);
  try {
    const [gardeners, plants, listings, orders] = await Promise.all([
      request("/api/gardeners/").catch(() => []),
      request("/api/plants/"),
      request("/api/listings/"),
      request("/api/orders/gardener/").catch(() => []),
    ]);

    // Grower profile
    const profile = Array.isArray(gardeners) ? gardeners[0] : gardeners;
    myGardenerProfileId = profile?.id ?? null;
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
                ${l.image ? `<img class="listing-thumb" src="${l.image}" alt="${l.plant_name || "Listing"} photo" loading="lazy" />` : ""}
                <strong>${l.plant_name || myPlants.find((p) => p.id === l.plant)?.name || `Plant #${l.plant}`}</strong>
                <label>Price <input type="number" step="0.01" name="price" value="${l.price}" /></label>
                <label>Qty <input type="number" name="quantity_available" value="${l.quantity_available}" /></label>
                <label>Status
                  <select name="status">
                    <option value="active"${l.status === "active" ? " selected" : ""}>Active</option>
                    <option value="paused"${l.status === "paused" ? " selected" : ""}>Paused</option>
                    <option value="sold_out"${l.status === "sold_out" ? " selected" : ""}>Sold out</option>
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
        const readyableStatuses = new Set(["SCHEDULED", "AWAITING_PICKUP_SCHEDULING"]);
        ordersEl.innerHTML = orders
          .map((o) => {
            const items = (o.items || [])
              .map((i) => `<li>${i.plant_name || `Listing #${i.listing}`} &times; ${i.quantity}</li>`)
              .join("");
            const action = readyableStatuses.has(o.status)
              ? `<button class="button primary" data-mark-ready="${o.id}">Mark ready for pickup</button>`
              : "";
            return `
              <div class="order-card panel">
                <h3>Order #${o.id}</h3>
                <span class="pill">${o.status}</span>
                <p>Pickup: ${o.pickup_date || "--"} &middot; ${o.pickup_window || "--"}</p>
                <ul>${items}</ul>
                ${action}
              </div>
            `;
          })
          .join("");

        ordersEl.querySelectorAll("[data-mark-ready]").forEach((btn) => {
          btn.addEventListener("click", async () => {
            btn.disabled = true;
            const original = btn.textContent;
            btn.textContent = "Marking...";
            try {
              await request(`/api/orders/${btn.dataset.markReady}/mark_ready/`, { method: "POST" });
              initDashboard();
            } catch (error) {
              btn.disabled = false;
              btn.textContent = original;
              showError(ordersEl, error.message);
            }
          });
        });
      }
    }
  } catch (error) {
    if (listingsTable) {
      listingsTable.innerHTML = "";
      showError(listingsTable, `Could not load dashboard data: ${error.message}`);
    }
  }

  // Create plant
  if (createPlantForm) {
    createPlantForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      const submitBtn = createPlantForm.querySelector('[type="submit"]');
      submitBtn.disabled = true;
      submitBtn.textContent = "Adding...";

      if (!myGardenerProfileId) {
        showError(createPlantForm.parentElement, "Could not find your gardener profile. Refresh and try again.");
        submitBtn.disabled = false;
        submitBtn.textContent = "Add plant";
        return;
      }

      const data = Object.fromEntries(new FormData(createPlantForm).entries());
      data.gardener = myGardenerProfileId;
      // Drop empty optional fields so the serializer sees blanks, not nulls.
      if (!data.grow_method) delete data.grow_method;
      if (!data.species) delete data.species;
      if (!data.description) delete data.description;

      try {
        await request("/api/plants/", {
          method: "POST",
          body: JSON.stringify(data),
        });
        setMessage(plantMsg, `Plant "${data.name}" added.`);
        createPlantForm.reset();
        initDashboard();
      } catch (error) {
        showError(createPlantForm.parentElement, error.message);
        setMessage(plantMsg, error.message);
      } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = "Add plant";
      }
    });
  }

  // Create listing
  if (createForm) {
    createForm.addEventListener("submit", async (event) => {
      event.preventDefault();
      const submitBtn = createForm.querySelector('[type="submit"]');
      submitBtn.disabled = true;
      submitBtn.textContent = "Creating...";

      const formData = new FormData(createForm);
      const plantValue = formData.get("plant");
      if (!plantValue) {
        showError(createForm.parentElement, "Please select a plant.");
        submitBtn.disabled = false;
        submitBtn.textContent = "Create listing";
        return;
      }

      const imageFile = formData.get("image");
      const hasImage = imageFile && imageFile instanceof File && imageFile.size > 0;
      // If no image was selected, drop the empty file entry so the backend
      // doesn't reject "" as an image, and post JSON for compactness.
      if (!hasImage) formData.delete("image");

      try {
        if (hasImage) {
          await request("/api/listings/", {
            method: "POST",
            body: formData,
            multipart: true,
          });
        } else {
          const data = Object.fromEntries(formData.entries());
          data.plant = Number(data.plant);
          data.quantity_available = Number(data.quantity_available);
          await request("/api/listings/", {
            method: "POST",
            body: JSON.stringify(data),
          });
        }
        setMessage(listingMsg, "Listing created!");
        createForm.reset();
        initDashboard();
      } catch (error) {
        showError(createForm.parentElement, error.message);
        setMessage(listingMsg, error.message);
      } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = "Create listing";
      }
    });
  }

  // Save listing changes (batch update)
  if (saveBtn) {
    saveBtn.addEventListener("click", async () => {
      saveBtn.disabled = true;
      saveBtn.textContent = "Saving...";

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
        showError(listingsTable, error.message);
        setMessage(saveMsg, error.message);
      } finally {
        saveBtn.disabled = false;
        saveBtn.textContent = "Save changes";
      }
    });
  }
};

document.addEventListener("DOMContentLoaded", initDashboard);
