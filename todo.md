# GardenMarket TODO — Demo prep

Goal: walk through the app live as a **seller (gardener)** and a **buyer** in
one continuous session, with no broken UX or "Listing #5" placeholders.

Pre-seeded accounts (after `make seed`, password `changeme`):
- `gardener@example.com`, `grower2@example.com`, `grower3@example.com` — role GARDENER
- *No buyer account yet — see "Demo content" below*

## Demo-blocking bugs (fix first)

- [x] **Role enum mismatch.** Frontend checks for `"GROWER"`, backend uses `GARDENER`. Seller cannot reach the dashboard right now.
  - `frontend/dashboard.js:25` — change `me.role !== "GROWER"` → `"GARDENER"`
  - `frontend/app.js:139` — change `role === "GROWER"` → `"GARDENER"`
- [x] **Listing type mismatch.** Form sends `CLONE`, backend expects `CLIPPING` (`backend/gardens/models.py:39`). Submit will 400.
  - `frontend/dashboard.html:56` — `<option value="CLONE">` → `"CLIPPING"`
  - `frontend/gallery.html:49` — same change in the filter dropdown
- [x] **Listings show only IDs, not plant names.** Add `plant_name` (or nested `plant`) to `ListingSerializer` (`backend/gardens/serializers.py:26`). Removes "Listing #5" UX everywhere it's referenced (`frontend/orders.js:29`, `frontend/checkout.js:33`, `frontend/gallery.js:20`, `frontend/dashboard.js:78`).

## Seller flow gaps

- [x] **No plant-creation UI.** Add a small form to `dashboard.html` that POSTs to `/api/plants/`. Today the listing form needs a plant id and gardeners have no way to create one through the UI.
- [x] **No image upload for listings.** Looks unfinished in the gallery.
  - Backend: add `image` (or M2M `photos`) to `Listing` + migration; surface in `ListingSerializer`.
  - Frontend: `<input type="file">` on the dashboard create-listing form; render the image in `gallery.js` and `dashboard.js`.
- [x] **No fulfillment action.** Seller can see incoming orders but can't update status. Add `POST /api/orders/{id}/mark_ready/` (or similar transitions) and a button in the dashboard order card.
- [x] **Dashboard listings table shows "Plant #N" fallback** (`frontend/dashboard.js:78`). Once `plant_name` is on the serializer, render that instead.
- [x] **Bonus: more enum mismatches** found during demo-blocker work — `SEED` should be `SEEDS`, `unit` was free-text but model takes `each|gram|lb|bundle`, `status` was uppercase but model uses lowercase. All fixed.

## Buyer flow gaps

- [x] **New: buyers without lat/lon can't check out.** Resolved by seeding `buyer@example.com` with Denver coords. Live registration still relies on the geocode signal; flagged in the demo script as a known rough edge.
- [x] **Centers page shows "?" capacity** until a date filter is applied (`backend/logistics/views.py:38`, surfaced at `frontend/centers.js:37`). Default `remaining_capacity` to today's date so the first paint is informative.
- [x] **Orders page is sparse.** Buyer should see plant name + pickup window + check-in code in one view. Now shows plant_name, listing_unit, price, and friendly status labels (Ready for pickup, Scheduled, etc.).
- [x] **No way to clear or update a cart item** before checkout. Cart now has a quantity input that PATCHes `/api/cart/{id}/` and the Remove button.

## Demo content

- [x] Extend `backend/gardens/management/commands/seed_data.py`:
  - Create a seeded buyer: `buyer@example.com / changeme` (role CONSUMER, Denver coords).
  - Create 4 community posts with photos via `mediahub`.
  - Attach a generated photo to 10 listings.
- [x] Commit ~10 stock plant/produce photos. Done via Pillow primitives in seed_data — no real stock photography needed; images are rebuilt on `make seed`.

## Demo logistics

- [x] Add `make demo-reset` (also `make e2e` for the smoke suite).
- [x] Write `docs/demo-script.md` with the click-by-click walkthrough.
- [x] Dry-run end-to-end via the public API: buyer login, add to cart, PATCH quantity, place order, mock_pay → SCHEDULED, gardener mark_ready → READY_FOR_PICKUP, buyer sees the new status. Centers default capacity is now informative on first paint.

## Nice-to-have (after the demo lands)

- [ ] Replace the auto-rotating gallery carousel with a 3-column grid; the carousel is overkill for the current density.
- [ ] Wire real Stripe (test keys) so checkout flows through `payment_intents` instead of `mock_pay`.
- [ ] Add a buyer review/rating endpoint after order completion so the gardener `rating_avg` / `rating_count` fields actually populate.
- [ ] Document the `ProfileView` permission policy (`backend/accounts/views.py:22`) — currently relies on project default, would benefit from explicit `permission_classes = [IsAuthenticated]`.
