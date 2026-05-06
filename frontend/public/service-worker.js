// Vite produces hashed asset filenames (e.g. /assets/app-abc123.js), so we
// don't pre-cache them by name. Instead we pre-cache the unhashed shell
// (HTML pages + manifest + icons + offline page) and runtime-cache the
// hashed assets as they're fetched. Bump CACHE_NAME to invalidate.
const CACHE_NAME = "gardenmarket-shell-v5";
const RUNTIME_CACHE = "gardenmarket-runtime-v5";
const OFFLINE_URL = "/offline.html";

const SHELL_ASSETS = [
  "/",
  "/index.html",
  "/gallery.html",
  "/grow-with-us.html",
  "/register.html",
  "/terms.html",
  "/privacy.html",
  "/seller-agreement.html",
  "/cart.html",
  "/checkout.html",
  "/orders.html",
  "/profile.html",
  "/dashboard.html",
  "/community.html",
  "/centers.html",
  "/offline.html",
  "/manifest.json",
  "/icon.svg",
  "/icon-192.png",
  "/icon-512.png",
  "/icon-maskable-512.png",
  "/apple-touch-icon.png",
  "/favicon.ico",
  "/favicon-32.png",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches
      .open(CACHE_NAME)
      .then((cache) => cache.addAll(SHELL_ASSETS))
      .then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  const allowed = new Set([CACHE_NAME, RUNTIME_CACHE]);
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((k) => !allowed.has(k)).map((k) => caches.delete(k)))
      )
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;

  const url = new URL(request.url);

  // Same-origin only.
  if (url.origin !== self.location.origin) return;

  // Never intercept API or admin traffic.
  if (url.pathname.startsWith("/api/") || url.pathname.startsWith("/admin/")) {
    return;
  }

  // Navigation: network-first, fall back to cache, then offline page.
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE_NAME).then((c) => c.put(request, copy)).catch(() => {});
          return response;
        })
        .catch(() =>
          caches.match(request).then((cached) => cached || caches.match(OFFLINE_URL))
        )
    );
    return;
  }

  // Hashed assets (/assets/*): cache-first, fall back to network and store.
  if (url.pathname.startsWith("/assets/")) {
    event.respondWith(
      caches.match(request).then(
        (cached) =>
          cached ||
          fetch(request).then((response) => {
            const copy = response.clone();
            caches.open(RUNTIME_CACHE).then((c) => c.put(request, copy)).catch(() => {});
            return response;
          })
      )
    );
    return;
  }

  // Everything else (icons, manifest, fonts, etc.): cache-first, network fallback.
  event.respondWith(
    caches.match(request).then((cached) => cached || fetch(request))
  );
});
