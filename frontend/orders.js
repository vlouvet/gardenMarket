const STATUS_COLORS = {
  AWAITING_PICKUP_SCHEDULING: "",
  SCHEDULED: "accent-2",
  COMPLETE: "accent-2",
  CANCELLED: "ghost",
};

const loadOrders = async () => {
  if (!requireAuth()) return;

  const container = document.getElementById("orders-list");
  if (!container) return;

  container.innerHTML = "<p>Loading orders...</p>";

  try {
    const orders = await request("/api/orders/");

    if (orders.length === 0) {
      container.innerHTML = "<p>No orders yet. <a href='gallery.html'>Start shopping</a></p>";
      return;
    }

    container.innerHTML = orders
      .map((o) => {
        const items = (o.items || [])
          .map((i) => `<li>Listing #${i.listing} &times; ${i.quantity}</li>`)
          .join("");
        const statusClass = STATUS_COLORS[o.status] || "";
        return `
          <article class="panel order-card">
            <div class="order-header">
              <h3>Order #${o.id}</h3>
              <span class="pill${statusClass ? " " + statusClass : ""}">${o.status}</span>
            </div>
            <p>Pickup: ${o.pickup_date || "--"} &middot; ${o.pickup_window || "--"}</p>
            <p>Payment: ${o.payment_status || "--"} &middot; Check-in: <code>${o.checkin_code || "N/A"}</code></p>
            <p class="order-date">Placed ${o.created_at ? new Date(o.created_at).toLocaleDateString() : "--"}</p>
            ${items ? `<ul class="order-items">${items}</ul>` : ""}
          </article>
        `;
      })
      .join("");
  } catch (error) {
    container.innerHTML = `<p>${error.message}</p>`;
  }
};

document.addEventListener("DOMContentLoaded", loadOrders);
