let listingCache = {};

const loadCart = async () => {
  if (!requireAuth()) return;

  const container = document.getElementById("cart-items");
  const footer = document.getElementById("cart-footer");
  const totalEl = document.getElementById("cart-total");
  if (!container) return;

  container.innerHTML = "<p>Loading cart...</p>";

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
        const price = Number(listing.price) || 0;
        const lineTotal = price * item.quantity;
        total += lineTotal;
        return `
          <div class="cart-item panel">
            <div class="cart-item-info">
              <h3>${listing.plant || `Listing #${item.listing}`}</h3>
              <p>${listing.type || ""} &middot; $${price.toFixed(2)} &times; ${item.quantity}</p>
              <strong>$${lineTotal.toFixed(2)}</strong>
            </div>
            <button class="button ghost" data-cart-item="${item.id}">Remove</button>
          </div>
        `;
      })
      .join("");

    if (totalEl) totalEl.textContent = `$${total.toFixed(2)}`;
    if (footer) footer.style.display = "";

    container.querySelectorAll("[data-cart-item]").forEach((btn) => {
      btn.addEventListener("click", async () => {
        try {
          await request(`/api/cart/${btn.dataset.cartItem}/`, { method: "DELETE" });
          loadCart();
        } catch (error) {
          btn.textContent = error.message;
        }
      });
    });
  } catch (error) {
    container.innerHTML = `<p>${error.message}</p>`;
  }
};

document.addEventListener("DOMContentLoaded", loadCart);
