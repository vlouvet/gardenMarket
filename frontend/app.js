export const API_BASE =
  document.querySelector('meta[name="api-base"]')?.getAttribute("content") || "";
export const TOKEN_KEY = "gardenmarket_access_token";
export const USER_KEY = "gardenmarket_user";

/* ── helpers ─────────────────────────────────────────────────── */

export const setMessage = (el, message, tone = "") => {
  if (!el) return;
  el.textContent = message;
  el.dataset.tone = tone;
};

/* ── auth state ──────────────────────────────────────────────── */

export const storeToken = (token) => localStorage.setItem(TOKEN_KEY, token);
export const getToken = () => localStorage.getItem(TOKEN_KEY);

export const storeUser = (user) => localStorage.setItem(USER_KEY, JSON.stringify(user));
export const getUser = () => {
  try { return JSON.parse(localStorage.getItem(USER_KEY)); } catch { return null; }
};

export const logout = () => {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem(USER_KEY);
  window.location.href = "index.html";
};

export const requireAuth = () => {
  if (!getToken()) {
    window.location.href = "register.html";
    return false;
  }
  return true;
};

/**
 * Fetch the current user from /api/accounts/me/ and cache in localStorage.
 * Called on every page load when a token exists. If the token is invalid/expired
 * the API will 401 and we clear credentials and redirect.
 */
export const refreshCurrentUser = async () => {
  const token = getToken();
  if (!token) return null;
  try {
    const me = await request("/api/accounts/me/");
    storeUser(me);
    return me;
  } catch {
    // Token invalid or expired — clear and redirect
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    const page = document.body.dataset.page;
    const protectedPages = ["cart", "orders", "checkout", "profile", "dashboard"];
    if (protectedPages.includes(page)) {
      window.location.href = "register.html";
    }
    return null;
  }
};

/* ── API request wrapper ─────────────────────────────────────── */

export const request = async (path, options = {}) => {
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
    const detail = data.detail || response.statusText || "Request failed";
    const err = new Error(detail);
    err.status = response.status;
    throw err;
  }
  return data;
};

/* ── loading spinner helpers ─────────────────────────────────── */

export const showLoading = (container) => {
  if (!container) return;
  container.innerHTML = '<div class="loading-spinner" role="status" aria-live="polite" aria-label="Loading"><span></span></div>';
};

export const hideLoading = (container) => {
  if (!container) return;
  const spinner = container.querySelector(".loading-spinner");
  if (spinner) spinner.remove();
};

/* ── error banner helpers ────────────────────────────────────── */

export const showError = (container, message) => {
  if (!container) return;
  dismissError(container);
  const banner = document.createElement("div");
  banner.className = "error-banner";
  banner.setAttribute("role", "alert");
  banner.innerHTML = `<span>${message}</span><button class="error-dismiss" aria-label="Dismiss">&times;</button>`;
  banner.querySelector(".error-dismiss").addEventListener("click", () => banner.remove());
  container.prepend(banner);
};

export const dismissError = (container) => {
  if (!container) return;
  container.querySelectorAll(".error-banner").forEach((b) => b.remove());
};

/* ── navigation ──────────────────────────────────────────────── */

export const initNav = () => {
  const nav = document.querySelector(".nav-links");
  if (!nav) return;
  if (!nav.hasAttribute("aria-label")) nav.setAttribute("aria-label", "Primary");
  const loggedIn = !!getToken();
  const user = getUser();
  const role = user?.role || "";

  const links = [
    '<a href="index.html">Home</a>',
    '<a href="gallery.html">Gallery</a>',
    '<a href="centers.html">Centers</a>',
    '<a href="community.html">Community</a>',
  ];

  if (loggedIn) {
    links.push('<a href="cart.html">Cart</a>');
    links.push('<a href="orders.html">Orders</a>');
    if (role === "GARDENER" || role === "ADMIN") {
      links.push('<a href="dashboard.html">Dashboard</a>');
    }
    links.push('<a href="profile.html">Profile</a>');
    links.push('<a href="grow-with-us.html">Grow With Us</a>');
    links.push('<button class="nav-logout" id="nav-logout">Sign out</button>');
  } else {
    links.push('<a href="grow-with-us.html">Grow With Us</a>');
    links.push('<a href="register.html">Register</a>');
  }

  nav.innerHTML = links.join("");

  const logoutBtn = nav.querySelector("#nav-logout");
  if (logoutBtn) {
    logoutBtn.addEventListener("click", logout);
  }
};

/* ── page init ───────────────────────────────────────────────── */

const initPage = async () => {
  initNav();
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("/service-worker.js").catch(() => undefined);
  }
  // Validate token & refresh cached user on every page load
  const user = await refreshCurrentUser();
  if (user) initNav(); // re-render nav with role info
};

document.addEventListener("DOMContentLoaded", initPage);
