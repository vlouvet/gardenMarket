import { request, requireAuth, showLoading, showError } from "./app.js";

let listingCache = {};

const loadCart = async () => {
  if (!requireAuth()) return;

  const container = document.getElementById("cart-items");
  const footer = document.getElementById("cart-footer");
  const totalEl = document.getElementById("cart-total");
  if (!container) return;

  showLoading(container);

  try {
    const [cart, listings] = await Promise.all([
      request("/api/cart/"),
      request("/api/listings/"),
    ]);

    listingCache = {};
    for (const l of listings) {
      listingCache[l.id] = l;
    }

    const items = cart.items || [];
    if (items.length === 0) {
      container.innerHTML = "<p>Your cart is empty. <a href='gallery.html'>Browse the gallery</a></p>";
      if (footer) footer.style.display = "none";
      return;
    }

    let total = 0;
    container.innerHTML = items
      .map((item) => {
        const listing = listingCache[item.listing] || {};
        const price = Number(item.listing_price ?? listing.price) || 0;
        const name = item.plant_name || listing.plant_name || `Listing #${item.listing}`;
        const type = item.listing_type || listing.type || "";
        const unit = item.listing_unit || listing.unit || "";
        const lineTotal = price * item.quantity;
        total += lineTotal;
        return `
          <div class="cart-item panel">
            <div class="cart-item-info">
              <h3>${name}</h3>
              <p>${type}${unit ? ` &middot; ${unit}` : ""} &middot; $${price.toFixed(2)} ea.</p>
              <strong>$${lineTotal.toFixed(2)}</strong>
            </div>
            <div class="cart-item-controls">
              <label class="cart-qty">Qty
                <input type="number" min="1" value="${item.quantity}" data-cart-qty="${item.id}" />
              </label>
              <button class="button ghost" data-cart-item="${item.id}">Remove</button>
            </div>
          </div>
        `;
      })
      .join("");

    if (totalEl) totalEl.textContent = `$${total.toFixed(2)}`;
    if (footer) footer.style.display = "";

    container.querySelectorAll("[data-cart-item]").forEach((btn) => {
      btn.addEventListener("click", async () => {
        btn.disabled = true;
        btn.textContent = "Removing...";
        try {
          await request(`/api/cart/${btn.dataset.cartItem}/`, { method: "DELETE" });
          loadCart();
        } catch (error) {
          btn.disabled = false;
          btn.textContent = "Remove";
          showError(container, error.message);
        }
      });
    });

    container.querySelectorAll("[data-cart-qty]").forEach((input) => {
      input.addEventListener("change", async () => {
        const id = input.dataset.cartQty;
        const next = Number(input.value);
        if (!Number.isFinite(next) || next < 1) {
          input.value = 1;
          return;
        }
        input.disabled = true;
        try {
          await request(`/api/cart/${id}/`, {
            method: "PATCH",
            body: JSON.stringify({ quantity: next }),
          });
          loadCart();
        } catch (error) {
          input.disabled = false;
          showError(container, error.message);
        }
      });
    });
  } catch (error) {
    container.innerHTML = "";
    showError(container, error.status === 401 ? "Session expired. Please sign in again." : `Could not load cart: ${error.message}`);
  }
};

document.addEventListener("DOMContentLoaded", loadCart);
