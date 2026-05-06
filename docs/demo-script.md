# GardenMarket demo script

A 5–8 minute walkthrough that shows the marketplace from both sides
(gardener and buyer) ending with a fulfilled order. Everything below is
verified end-to-end against a clean `make demo-reset`.

## 0. One-time setup

From the project root:

```sh
make demo-reset
```

This wipes the DB and MinIO volumes, brings the stack back up, runs
migrations, seeds 3 gardeners + 1 buyer + 110 listings + 10 listing
photos + 4 community posts, and makes the MinIO bucket publicly
readable so listing images render in the browser.

When it finishes, you'll see:

```
Demo ready. Open http://localhost:8881
  Gardener: gardener@example.com / changeme
  Buyer:    buyer@example.com / changeme
```

If the stack was already up and you just want fresh content (no DB
wipe), `make seed` is enough.

## 1. Walking the home and gallery (no login, ~30s)

1. Open http://localhost:8881/
2. Point out the hero strip — the "Active listings" and "Distribution
   hubs" tiles are populated from `/api/listings/` and `/api/centers/`,
   not hard-coded.
3. Click **Produce Gallery**.
4. Hit **Next** a few times. Highlight that the carousel auto-rotates
   but **pauses on hover/focus** and respects `prefers-reduced-motion`.
   Listings show plant name, price, pickup window, and (for ~10 of
   them) a photo.
5. Filter to **Clippings** — five seeded clipping listings appear.

## 2. Buyer flow (~3 minutes)

1. From any page, click **Register** in the nav.
2. On the right ("Already registered?"), sign in:
   - Email: `buyer@example.com`
   - Password: `changeme`

   The nav rewrites to include **Cart**, **Orders**, **Profile**.

3. Click **Gallery**, pick a listing with a photo, click **Add to cart**.
4. Click **Cart**. Bump the quantity input from 1 → 3 (PATCHes
   `/api/cart/{id}/`) and watch the line total update on reload.
   Optional: hit **Remove** on a different item.
5. Click **Checkout**.
6. Pick **Denver Hub** as the distribution center. The window dropdown
   updates from the center's pickup_windows.
7. Click **Place order**. The page replaces the form with the order
   confirmation, including a **check-in code**. The mock-pay endpoint
   fires automatically; the order is now `SCHEDULED`.
8. Click **View your orders**. The order card shows plant names
   (e.g. "Basil") and quantity, the friendly status pill ("Scheduled"),
   and the check-in code.

## 3. Gardener flow (~3 minutes)

1. Top-right **Sign out**.
2. Sign in as the gardener:
   - Email: `gardener@example.com`
   - Password: `changeme`

   **Dashboard** appears in the nav now that the role is GARDENER.

3. Click **Dashboard**.

   Three sections to walk through:

   - **Add a Plant** — enter "Sungold Tomato", species "Solanum
     lycopersicum", grow method Soil. Submit. The plant immediately
     populates the dropdown below.
   - **Create Listing** — pick the new plant, type Produce, unit lb,
     price 4.50, qty 12, pickup "Sat 9-12". Attach an image (any small
     JPG works). Submit. The new listing appears in **Your Listings**
     with a thumbnail.
   - **Orders for Your Items** — the buyer's order from §2 appears
     here with the plant name and quantity. Click **Mark ready for
     pickup**. The status changes to `READY_FOR_PICKUP`.

4. (Optional) Sign back in as the buyer. Open **Orders**. The same
   order now shows status **Ready for pickup**.

## 4. Community feed (~30s)

Click **Community** while signed in as either user. Four seeded posts
with photos appear. Logged-in users see the "Share an update" form;
posting attaches an optional photo to the feed.

## 5. Centers and capacity (~30s)

Click **Centers**. Each center now shows `capacity / total` for today
(no date-filter required — the API defaults to today's date). The
buyer's order from §2 reduced **Denver Hub**'s remaining capacity by
one.

## Talking points worth pre-loading

- Frontend is a Vite-built static site (MPA, hashed assets) served by
  nginx. Page reloads do not lose progress because the SW cache is
  versioned and runtime-caches anything under `/assets/*`.
- All buyer ↔ gardener traffic flows through `/api/`, proxied to
  Django. The same backend powers the admin at `/admin/`.
- Image uploads land in MinIO via `django-storages`; URLs are rewritten
  to `localhost:9000` in dev so the browser can fetch them directly.
- Run `make e2e` any time to fire the Playwright smoke suite against
  the running stack.

## Known rough edges to glide past

- A buyer registered live (not via seed) will need to set their address
  before checkout — the eligibility check needs `lat/lon`. The seeded
  buyer already has Denver coordinates.
- Stripe is not wired up; the mock_pay shortcut stands in. Real card
  payment is a follow-up.
- Reviews / ratings exist as model fields but the UI to leave a rating
  after pickup isn't built yet.
