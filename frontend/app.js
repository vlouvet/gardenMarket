const API_BASE =
  document.querySelector('meta[name="api-base"]')?.getAttribute("content") || "";
const TOKEN_KEY = "gardenmarket_access_token";

const setMessage = (el, message, tone = "") => {
  if (!el) return;
  el.textContent = message;
  el.dataset.tone = tone;
};

const request = async (path, options = {}) => {
  const headers = { ...(options.headers || {}) };
  if (!options.multipart) {
    headers["Content-Type"] = "application/json";
  }
  const token = getToken();
  if (token) {
    headers["Authorization"] = `Bearer ${token}`;
  }
  const response = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
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

const requireAuth = () => {
  if (!getToken()) {
    window.location.href = "register.html";
    return false;
  }
  return true;
};

const initNav = () => {
  const nav = document.querySelector(".nav-links");
  if (!nav) return;
  const loggedIn = !!getToken();
  nav.innerHTML = [
    '<a href="index.html">Home</a>',
    '<a href="gallery.html">Gallery</a>',
    '<a href="centers.html">Centers</a>',
    '<a href="community.html">Community</a>',
    loggedIn ? '<a href="cart.html">Cart</a>' : "",
    loggedIn ? '<a href="orders.html">Orders</a>' : "",
    loggedIn ? '<a href="profile.html">Profile</a>' : "",
    '<a href="grow-with-us.html">Grow With Us</a>',
    loggedIn ? "" : '<a href="register.html">Register</a>',
  ]
    .filter(Boolean)
    .join("");
};

const initPage = () => {
  initNav();
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("/service-worker.js").catch(() => undefined);
  }
};

document.addEventListener("DOMContentLoaded", initPage);
