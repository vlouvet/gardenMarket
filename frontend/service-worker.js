const CACHE_VERSION = 4;
const CACHE_NAME = `gardenmarket-static-v${CACHE_VERSION}`;
const OFFLINE_URL = "/offline.html";

const ASSETS = [
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
  "/favicon.ico",
  "/icons/icon.svg",
  "/icons/icon-192.png",
  "/icons/icon-512.png",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;

  const url = new URL(event.request.url);

  // For navigation requests, try network first then fall back to cache, then offline page
  if (event.request.mode === "navigate") {
    event.respondWith(
      fetch(event.request)
        .catch(() => caches.match(event.request))
        .then((response) => response || caches.match(OFFLINE_URL))
    );
    return;
  }

  // For static assets, try cache first then network
  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request))
  );
});
