// Bump CACHE_NAME on every release to invalidate old caches.
// Old caches are deleted on activate; clients claim immediately so the new
// SW takes effect on the next navigation without forcing a manual reload.
const CACHE_NAME = "gardenmarket-static-v4";
const OFFLINE_URL = "/offline.html";

const ASSETS = [
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
  "/styles.css",
  "/app.js",
  "/auth.js",
  "/grow.js",
  "/home.js",
  "/gallery.js",
  "/cart.js",
  "/checkout.js",
  "/orders.js",
  "/profile.js",
  "/dashboard.js",
  "/community.js",
  "/centers.js",
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
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
      )
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;

  // Never intercept API or admin traffic — always go to the network.
  const url = new URL(request.url);
  if (url.pathname.startsWith("/api/") || url.pathname.startsWith("/admin/")) {
    return;
  }

  // Navigation requests: network-first, fall back to cache, then offline page.
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Update cache opportunistically with the fresh page.
          const copy = response.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(request, copy)).catch(() => {});
          return response;
        })
        .catch(() =>
          caches.match(request).then((cached) => cached || caches.match(OFFLINE_URL))
        )
    );
    return;
  }

  // Static assets: cache-first, fall back to network.
  event.respondWith(
    caches.match(request).then((cached) => cached || fetch(request))
  );
});
