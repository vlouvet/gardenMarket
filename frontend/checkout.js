let centersData = [];

const initCheckout = async () => {
  if (!requireAuth()) return;

  const centerSelect = document.getElementById("center-select");
  const windowSelect = document.getElementById("window-select");
  const form = document.getElementById("checkout-form");
  const message = document.getElementById("checkout-message");
  const summary = document.getElementById("checkout-cart-summary");

  // Load cart summary
  if (summary) showLoading(summary);
  try {
    const [cart, listings] = await Promise.all([
      request("/api/cart/"),
      request("/api/listings/"),
    ]);
    const lookup = {};
    for (const l of listings) lookup[l.id] = l;

    const items = cart.items || [];
    if (items.length === 0) {
      if (summary) summary.innerHTML = "<p>Your cart is empty. <a href='gallery.html'>Add items first.</a></p>";
      return;
    }
    if (summary) {
      summary.innerHTML = items
        .map((item) => {
          const l = lookup[item.listing] || {};
          return `<p>${l.plant || `#${item.listing}`} &times; ${item.quantity} &mdash; $${(Number(l.price || 0) * item.quantity).toFixed(2)}</p>`;
        })
        .join("");
    }
  } catch (error) {
    if (summary) {
      summary.innerHTML = "";
      showError(summary, `Could not load cart: ${error.message}`);
    }
  }

  // Load centers
  try {
    centersData = await request("/api/centers/");
    centerSelect.innerHTML =
      '<option value="">Choose a center</option>' +
      centersData
        .map((c) => `<option value="${c.id}">${c.name} &mdash; ${c.city}, ${c.state}</option>`)
        .join("");
  } catch (error) {
    centerSelect.innerHTML = '<option value="">Could not load centers</option>';
    showError(form.parentElement, `Could not load centers: ${error.message}`);
  }

  centerSelect.addEventListener("change", () => {
    const center = centersData.find((c) => String(c.id) === centerSelect.value);
    const windows = center?.pickup_windows || [];
    windowSelect.innerHTML =
      windows.length === 0
        ? '<option value="">No pickup windows</option>'
        : windows.map((w) => `<option value="${w}">${w}</option>`).join("");
  });

  form.addEventListener("submit", async (event) => {
    event.preventDefault();

    // Basic validation
    if (!centerSelect.value) {
      showError(form.parentElement, "Please select a distribution center.");
      return;
    }

    const submitBtn = form.querySelector('[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.textContent = "Placing order...";
    dismissError(form.parentElement);

    const payload = Object.fromEntries(new FormData(form).entries());
    payload.distribution_center = Number(payload.distribution_center);

    try {
      const order = await request("/api/orders/", {
        method: "POST",
        body: JSON.stringify(payload),
      });

      // Attempt mock payment for demo
      try {
        await request(`/api/orders/${order.id}/mock_pay/`, { method: "POST" });
      } catch {
        // payment optional
      }

      form.style.display = "none";
      setMessage(
        message,
        `Order #${order.id} placed! Check-in code: ${order.checkin_code || "N/A"}. `
      );
      message.innerHTML += `<a class="button ghost" href="orders.html">View your orders</a>`;
    } catch (error) {
      showError(form.parentElement, error.message);
      setMessage(message, error.message);
    } finally {
      submitBtn.disabled = false;
      submitBtn.textContent = "Place order";
    }
  });
};

document.addEventListener("DOMContentLoaded", initCheckout);
