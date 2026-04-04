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
  label.textContent = item.type || "Listing";
  card.innerHTML = `
    <h3>${item.plant || "Unnamed"}</h3>
    <strong>$${Number(item.price).toFixed(2)}</strong>
    <p>${item.unit ? item.unit + " \u2022 " : ""}${item.pickup_window || ""}</p>
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
      try {
        await request("/api/cart/", {
          method: "POST",
          body: JSON.stringify({ listing: item.id, quantity: 1 }),
        });
        addBtn.textContent = "Added!";
        addBtn.disabled = true;
      } catch (error) {
        addBtn.textContent = error.message;
      }
    });
  }
};

const loadAndBindCarousel = async () => {
  const card = document.getElementById("carousel-card");
  const prev = document.getElementById("prev-item");
  const next = document.getElementById("next-item");
  const filter = document.getElementById("listing-filter");
  if (!card) return;

  const fetchListings = async (type) => {
    const params = type ? `?type=${type}` : "";
    try {
      card.innerHTML = "<p>Loading listings...</p>";
      carouselItems = await request(`/api/listings/${params}`);
      carouselIndex = 0;
      renderCarousel();
    } catch {
      card.innerHTML = "<p>Could not load listings.</p>";
    }
  };

  await fetchListings();

  if (prev && next) {
    prev.addEventListener("click", () => {
      if (carouselItems.length === 0) return;
      carouselIndex = (carouselIndex - 1 + carouselItems.length) % carouselItems.length;
      renderCarousel();
    });

    next.addEventListener("click", () => {
      if (carouselItems.length === 0) return;
      carouselIndex = (carouselIndex + 1) % carouselItems.length;
      renderCarousel();
    });

    setInterval(() => {
      if (carouselItems.length === 0) return;
      carouselIndex = (carouselIndex + 1) % carouselItems.length;
      renderCarousel();
    }, 7000);
  }

  if (filter) {
    filter.addEventListener("change", () => fetchListings(filter.value));
  }
};

document.addEventListener("DOMContentLoaded", loadAndBindCarousel);
