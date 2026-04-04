const CACHE_NAME = "gardenmarket-static-v3";
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
];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS)));
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;
  event.respondWith(
    caches.match(event.request).then((cached) => cached || fetch(event.request))
  );
});
