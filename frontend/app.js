const API_BASE = "";
const TOKEN_KEY = "gardenmarket_access_token";

const carouselItems = [
  {
    category: "Seeds",
    title: "Heirloom Tomato Seeds",
    price: "$4.50",
    description: "Sun-loving, sweet, and resilient. Best for spring starts.",
  },
  {
    category: "Seeds",
    title: "Purple Basil Seeds",
    price: "$3.25",
    description: "Aromatic and fast germinating with deep purple leaves.",
  },
  {
    category: "Clones",
    title: "Strawberry Clone",
    price: "$7.00",
    description: "Rooted starter with established runners.",
  },
  {
    category: "Clones",
    title: "Mint Clone",
    price: "$5.00",
    description: "Hardy cutting, perfect for teas and cocktails.",
  },
  {
    category: "Produce",
    title: "Rainbow Chard Bundle",
    price: "$6.25",
    description: "Harvested within 24 hours, crisp and colorful.",
  },
  {
    category: "Produce",
    title: "Cherry Tomato Pint",
    price: "$5.75",
    description: "Sweet, snackable, and never shipped long distance.",
  },
];

let carouselIndex = 0;

const setMessage = (el, message, tone = "") => {
  if (!el) return;
  el.textContent = message;
  el.dataset.tone = tone;
};

const request = async (path, options) => {
  const response = await fetch(`${API_BASE}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...(options?.headers || {}),
    },
    ...options,
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const detail = data.detail || "Request failed";
    throw new Error(detail);
  }
  return data;
};

const storeToken = (token) => {
  localStorage.setItem(TOKEN_KEY, token);
};

const getToken = () => localStorage.getItem(TOKEN_KEY);

const bindRegister = () => {
  const form = document.getElementById("register-form");
  const message = document.getElementById("register-message");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const payload = Object.fromEntries(formData.entries());

    try {
      await request("/api/accounts/register/", {
        method: "POST",
        body: JSON.stringify(payload),
      });
      const login = await request("/api/accounts/login/", {
        method: "POST",
        body: JSON.stringify({
          email: payload.email,
          password: payload.password,
        }),
      });
      storeToken(login.access);
      setMessage(message, "Account created. Access token stored.");
    } catch (error) {
      setMessage(message, error.message);
    }
  });
};

const bindLogin = () => {
  const form = document.getElementById("login-form");
  const message = document.getElementById("login-message");
  if (!form) return;

  form.addEventListener("submit", async (event) => {
    event.preventDefault();
    const formData = new FormData(form);
    const payload = Object.fromEntries(formData.entries());

    try {
      const login = await request("/api/accounts/login/", {
        method: "POST",
        body: JSON.stringify(payload),
      });
      storeToken(login.access);
      setMessage(message, "Signed in. Access token stored.");
    } catch (error) {
      setMessage(message, error.message);
    }
  });
};

const renderCarousel = () => {
  const card = document.getElementById("carousel-card");
  const label = document.getElementById("carousel-label");
  if (!card || !label) return;
  const item = carouselItems[carouselIndex];
  label.textContent = item.category;
  card.innerHTML = `
    <h3>${item.title}</h3>
    <strong>${item.price}</strong>
    <p>${item.description}</p>
    <span class="pill">Available now</span>
  `;
};

const bindCarousel = () => {
  const prev = document.getElementById("prev-item");
  const next = document.getElementById("next-item");
  if (!prev || !next) return;

  renderCarousel();

  prev.addEventListener("click", () => {
    carouselIndex = (carouselIndex - 1 + carouselItems.length) % carouselItems.length;
    renderCarousel();
  });

  next.addEventListener("click", () => {
    carouselIndex = (carouselIndex + 1) % carouselItems.length;
    renderCarousel();
  });

  setInterval(() => {
    carouselIndex = (carouselIndex + 1) % carouselItems.length;
    renderCarousel();
  }, 7000);
};

const bindUpgrade = () => {
  const button = document.getElementById("upgrade-button");
  const message = document.getElementById("upgrade-message");
  if (!button) return;

  button.addEventListener("click", async () => {
    const token = getToken();
    if (!token) {
      setMessage(message, "Sign in to store a token before upgrading.");
      return;
    }

    try {
      const data = await request("/api/accounts/upgrade/", {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });
      setMessage(message, `Upgrade complete. New role: ${data.role}.`);
    } catch (error) {
      setMessage(message, error.message);
    }
  });
};

const initPage = () => {
  bindRegister();
  bindLogin();
  bindCarousel();
  bindUpgrade();
};

document.addEventListener("DOMContentLoaded", initPage);
