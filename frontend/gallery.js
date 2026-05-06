import { request, requireAuth, showLoading, showError } from "./app.js";

let carouselItems = [];
let carouselIndex = 0;

const renderCarousel = () => {
  const card = document.getElementById("carousel-card");
  const label = document.getElementById("carousel-label");
  if (!card || !label) return;

  if (carouselItems.length === 0) {
    label.textContent = "";
    card.innerHTML = "<p>No listings available.</p>";
    return;
  }

  const item = carouselItems[carouselIndex];
  label.textContent = `${item.type || "Listing"} (${carouselIndex + 1} of ${carouselItems.length})`;
  card.innerHTML = `
    <h3>${item.plant || "Unnamed"}</h3>
    <strong>$${Number(item.price).toFixed(2)}</strong>
    <p>${item.unit ? item.unit + " • " : ""}${item.pickup_window || ""}</p>
    <div class="badge-row">
      ${item.in_stock ? '<span class="pill">Available now</span>' : '<span class="pill ghost">Out of stock</span>'}
      ${item.pickup_days ? `<span class="pill ghost">Pickup: ${item.pickup_days}</span>` : ""}
    </div>
    <button class="button primary" data-listing-id="${item.id}">Add to cart</button>
  `;

  const addBtn = card.querySelector("[data-listing-id]");
  if (addBtn) {
    addBtn.addEventListener("click", async () => {
      if (!requireAuth()) return;
      addBtn.disabled = true;
      addBtn.textContent = "Adding...";
      try {
        await request("/api/cart/", {
          method: "POST",
          body: JSON.stringify({ listing: item.id, quantity: 1 }),
        });
        addBtn.textContent = "Added!";
      } catch (error) {
        addBtn.disabled = false;
        addBtn.textContent = "Add to cart";
        showError(card, error.message);
      }
    });
  }
};

const advance = (delta) => {
  if (carouselItems.length === 0) return;
  carouselIndex = (carouselIndex + delta + carouselItems.length) % carouselItems.length;
  renderCarousel();
};

const loadAndBindCarousel = async () => {
  const card = document.getElementById("carousel-card");
  const prev = document.getElementById("prev-item");
  const next = document.getElementById("next-item");
  const filter = document.getElementById("listing-filter");
  const region = card?.closest(".carousel");
  if (!card) return;

  const fetchListings = async (type) => {
    const params = type ? `?type=${type}` : "";
    try {
      showLoading(card);
      carouselItems = await request(`/api/listings/${params}`);
      carouselIndex = 0;
      renderCarousel();
    } catch (error) {
      card.innerHTML = "";
      showError(card, `Could not load listings: ${error.message}`);
    }
  };

  await fetchListings();

  if (prev) prev.addEventListener("click", () => advance(-1));
  if (next) next.addEventListener("click", () => advance(1));

  // Keyboard navigation: arrow keys when carousel has focus, plus Home/End.
  if (region) {
    region.addEventListener("keydown", (event) => {
      switch (event.key) {
        case "ArrowLeft":
          event.preventDefault();
          advance(-1);
          break;
        case "ArrowRight":
          event.preventDefault();
          advance(1);
          break;
        case "Home":
          event.preventDefault();
          if (carouselItems.length) {
            carouselIndex = 0;
            renderCarousel();
          }
          break;
        case "End":
          event.preventDefault();
          if (carouselItems.length) {
            carouselIndex = carouselItems.length - 1;
            renderCarousel();
          }
          break;
      }
    });
  }

  // Auto-rotate, but pause on focus/hover and respect reduced-motion.
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  if (!reduceMotion && region) {
    let paused = false;
    const pause = () => { paused = true; };
    const resume = () => { paused = false; };
    region.addEventListener("focusin", pause);
    region.addEventListener("focusout", resume);
    region.addEventListener("mouseenter", pause);
    region.addEventListener("mouseleave", resume);
    document.addEventListener("visibilitychange", () => {
      paused = document.hidden;
    });
    setInterval(() => {
      if (paused || carouselItems.length === 0) return;
      advance(1);
    }, 7000);
  }

  if (filter) {
    filter.addEventListener("change", () => fetchListings(filter.value));
  }
};

document.addEventListener("DOMContentLoaded", loadAndBindCarousel);
