# GardenMarket TODO

## Frontend — Docker / Infrastructure Integration

- [x] Add an nginx service to docker-compose.yml to serve the static frontend and reverse-proxy `/api/` to the Django backend
- [x] Make `API_BASE` in app.js configurable (inject at build time or read from a `<meta>` tag) so the frontend can target different backend URLs per environment
- [x] Fix service-worker.js registration path — currently hardcoded to `/frontend/service-worker.js`, will break when served from nginx at `/`
- [x] Update service-worker.js cache list to match the actual served paths (currently assumes `/frontend/` prefix)

## Frontend — API Integration

- [x] Replace hardcoded carousel items in app.js with a fetch to `GET /api/listings/` so the gallery shows real data
- [x] Replace hardcoded hero metrics (128 listings, 6 hubs, 72 miles) with live counts from the API
- [x] Add a shopping-cart page that calls `POST /api/cart/` and displays current cart items
- [x] Add an order-creation flow that calls `POST /api/orders/` after selecting a distribution center
- [x] Add an order-history / tracking page that calls `GET /api/orders/`
- [x] Add a user profile page that fetches and updates `GET/PATCH /api/accounts/profile/`
- [x] Add a grower dashboard page for managing listings (`GET/POST /api/listings/`, `GET /api/orders/gardener/`)
- [x] Integrate media uploads — allow growers to create posts and upload photos via `/api/posts/` and `/api/photos/`
- [x] Show distribution center locations fetched from `GET /api/centers/`

## Frontend — Auth & UX

- [x] Persist login state across page loads — redirect unauthenticated users away from protected pages
- [x] Show/hide navigation links based on auth state and user role (consumer vs gardener vs admin)
- [x] Add loading spinners or skeleton screens while API calls are in flight
- [x] Add proper error banners for failed API calls (network errors, 4xx, 5xx)
- [x] Add form validation feedback (inline errors, password-strength hints)
- [x] Add logout functionality (clear token, redirect to home)

## Frontend - images and assets
- [ ] create app icon and other required image asset files

## Frontend — PWA & Offline

- [ ] Add a web app manifest (manifest.json) with app name, icons, and theme color
- [ ] Add PWA meta tags to all HTML pages (`<meta name="theme-color">`, Apple touch icon, etc.)
- [ ] Add an offline fallback page shown when the network is unavailable
- [ ] Implement cache-busting for the service worker when static assets change

## Frontend — Quality & Accessibility

- [ ] Add ARIA labels and roles to interactive elements (carousel, forms, nav)
- [ ] Ensure all images have descriptive alt text
- [ ] Add keyboard navigation support for the gallery carousel
- [ ] Add a build step (e.g. Vite) for minification, bundling, and cache-busted filenames
- [ ] Add basic frontend tests (smoke tests for page load, form submission)


## Frontend — Content & Compliance

- [ ] Write real content for terms.html (currently a placeholder)
- [ ] Write real content for privacy.html (currently a placeholder)
- [ ] Write real content for seller-agreement.html (currently a placeholder)