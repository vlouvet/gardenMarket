const CACHE_NAME = "gardenmarket-static-v2";
const ASSETS = [
  "/index.html",
  "/gallery.html",
  "/grow-with-us.html",
  "/register.html",
  "/terms.html",
  "/privacy.html",
  "/seller-agreement.html",
  "/styles.css",
  "/app.js",
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
