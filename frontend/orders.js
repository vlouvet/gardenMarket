import { request, requireAuth, showLoading, showError } from "./app.js";

const STATUS_COLORS = {
  AWAITING_PICKUP_SCHEDULING: "",
  SCHEDULED: "accent-2",
  READY_FOR_PICKUP: "accent-2",
  COMPLETE: "accent-2",
  CANCELLED: "ghost",
};

const STATUS_LABELS = {
  AWAITING_PICKUP_SCHEDULING: "Awaiting pickup",
  SCHEDULED: "Scheduled",
  READY_FOR_PICKUP: "Ready for pickup",
  COMPLETE: "Complete",
  CANCELLED: "Cancelled",
  CREATED: "Created",
};

const loadOrders = async () => {
  if (!requireAuth()) return;

  const container = document.getElementById("orders-list");
  if (!container) return;

  showLoading(container);

  try {
    const orders = await request("/api/orders/");

    if (orders.length === 0) {
      container.innerHTML = "<p>No orders yet. <a href='gallery.html'>Start shopping</a></p>";
      return;
    }

    container.innerHTML = orders
      .map((o) => {
        const items = (o.items || [])
          .map((i) => {
            const name = i.plant_name || `Listing #${i.listing}`;
            const unit = i.listing_unit ? ` (${i.listing_unit})` : "";
            const price = i.price_at_purchase
              ? ` &mdash; $${Number(i.price_at_purchase).toFixed(2)} ea.`
              : "";
            return `<li>${name}${unit} &times; ${i.quantity}${price}</li>`;
          })
          .join("");
        const statusClass = STATUS_COLORS[o.status] || "";
        return `
          <article class="panel order-card">
            <div class="order-header">
              <h3>Order #${o.id}</h3>
              <span class="pill${statusClass ? " " + statusClass : ""}">${STATUS_LABELS[o.status] || o.status}</span>
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
    container.innerHTML = "";
    showError(container, `Could not load orders: ${error.message}`);
  }
};

document.addEventListener("DOMContentLoaded", loadOrders);
