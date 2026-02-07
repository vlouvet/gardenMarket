0) Repo bootstrap

 Create repo layout:

backend/ (Django project)

docker/ (Dockerfiles, init scripts)

docs/ (API examples, architecture notes)

 Add .gitignore (Python, Django, Postgres, media, .env, .venv)

 Add .env.example

 Add Makefile with common dev commands

1) Local dev with Docker Compose (simple ports)

Goal: docker compose up -d gives you API + DB + Redis + MinIO + workers.

 Create docker-compose.yml services:

 web (Django + DRF) expose 8000:8000

 db (Postgres) expose 5432:5432 (optional; can be internal only)

 redis expose 6379:6379 (optional)

 minio expose 9000:9000 and console 9001:9001

 worker (Celery worker)

 beat (Celery beat)

 Add healthchecks:

Postgres pg_isready

Redis ping

Web /health/

 Add named volumes:

pgdata

minio_data

 Ensure hot reload for Django (bind mount ./backend:/app)

 Add docker/Dockerfile for Django:

install deps

non-root user

run gunicorn for prod later, python manage.py runserver 0.0.0.0:8000 for dev now

 Add Makefile:

make up, make down, make logs, make bash, make migrate, make superuser, make test

2) Django project setup

 Create Django project: backend/config/

 Create apps:

 accounts (custom user, profiles)

 logistics (distribution centers + eligibility rules)

 gardens (gardener profiles, plants, listings)

 mediahub (posts, photos)

 market (cart, orders, mock payments)

 sensors (devices + readings, gardener-only)

 Dependencies:

Django

djangorestframework

django-filter

drf-spectacular (OpenAPI)

psycopg (or psycopg2-binary)

redis, celery

Pillow

django-storages, boto3 (MinIO/S3)

requests (for geocoding calls)

pytest, pytest-django, factory-boy

ruff, black, pre-commit

 Settings:

 env-based config (12-factor style)

 DATABASE_URL, REDIS_URL, S3_*, GEOCODING_PROVIDER, GEOCODING_API_KEY

 DEFAULT_AUTO_FIELD, timezone America/Denver

3) Location + Geocoding (Phase 1: address only)

Key constraint: both parties must be within 100 miles of at least one eligible distribution center for transactions.

 Store user location as:

address_line1, address_line2, city, state, postal_code, country

lat, lon (geocoded)

geocoded_at, geocode_confidence (optional)

 Implement geocoding service layer:

 logistics/services/geocode.py

 provider interface + implementation for one provider (Phase 1)

 retry/backoff + caching by normalized address hash

 Trigger geocoding:

 on profile save OR async via Celery task geocode_address_task(user_id)

 Add haversine distance function:

 logistics/utils/distance.py

 returns miles

 Eligibility logic:

 eligible_centers_for_location(lat, lon) within 100 miles

 validate_order_eligibility(consumer, gardener):

both must have lat/lon

intersection of eligible centers must be non-empty

 API filtering:

 GET /api/listings?address=... OR ?lat=...&lon=... (keep lat/lon optional for future)

For Phase 1, accept address and geocode it server-side for browsing (cache results).

4) Distribution Centers (can be proposed)

 DistributionCenter model:

name

address fields + lat/lon

status: PROPOSED, APPROVED, REJECTED, INACTIVE

proposed_by (user FK nullable)

notes / reason fields

 Center proposal flow:

 endpoint: POST /api/centers/propose

 auto-geocode on propose

 admin can approve/reject

 Browsing:

 endpoint: GET /api/centers?near=address to show nearby approved centers

5) Core models
Accounts

 Custom user model from day 1

 Roles: GARDENER, CONSUMER, ADMIN

 Profile: includes address + lat/lon

Gardens / plants / listings

 GardenerProfile:

user FK

bio

payout fields placeholder (for later)

 PlantProfile:

gardener FK

name/species

description

tags (grow conditions)

 Listing:

plant FK

type: CLIPPING, SEEDS, PRODUCE

unit: each, gram, lb, bundle

price

quantity_available

status active/paused/sold_out

Media

 Post:

gardener FK

plant FK optional

text

 Photo:

post FK

image file (MinIO)

Celery task creates thumbnails

Sensors (gardener-only)

 SensorDevice:

gardener FK

name, type, location_tag

api_token (rotateable)

 SensorReading:

device FK

timestamp

metric, value, unit

 Permissions:

only owner gardener can view readings/devices

 Ingest endpoint:

POST /api/sensors/ingest token auth

basic rate limit + validation

Market (mock payments)

 Cart, CartItem

 Order, OrderItem

 Order statuses:

CREATED, AWAITING_PICKUP_SCHEDULING, SCHEDULED, COMPLETE, CANCELLED

 Mock payment:

POST /api/orders/{id}/mock_pay sets status forward

store mock_payment_reference

6) API (DRF) and permissions

 DRF auth approach:

start with session auth + token auth OR JWT (pick one and implement)

 Endpoints (minimum):

accounts:

register/login/me/profile update

gardener:

CRUD plant profiles

CRUD listings

CRUD posts + photos upload

view orders related to their listings

consumer:

browse listings (with distance eligibility)

cart add/remove/view

checkout create order (requires eligibility)

select distribution center + pickup window (simple: select date/time string)

centers:

list approved

propose new center

admin:

approve/reject proposed centers

 Add OpenAPI:

/api/schema/

/api/docs/

7) Business rules (enforced server-side)

 A gardener cannot publish listings until:

they have geocoded location

they are within 100 miles of at least one APPROVED center

 A consumer cannot checkout until:

they have geocoded location

order has at least one gardener

there exists at least one center within 100 miles of both consumer and each gardener

 Order must choose a distribution center from the intersection set

8) Admin + moderation basics

 Django admin:

centers approve/reject

users/roles

listings moderation toggles (pause/hide)

 Reporting:

Report model (listing/user)

minimal endpoints for report submit

9) Seed data + developer UX

 Management command:

create sample centers (approved)

create sample gardeners + plants + listings

create sample posts/photos placeholders

 docs/api_examples.md:

curl examples for: register, propose center, create listing, browse listings, checkout

 pytest tests:

distance calc correctness

eligibility intersection

permission tests (sensor privacy)

Milestones

 MVP1 (2–4 days focused build):

accounts + profiles + geocoding

centers list + propose + admin approve

gardener plant/listing CRUD

consumer browse + cart + order + mock pay

 MVP2:

posts/photos + thumbnails

pickup scheduling workflow

 MVP3:

iOS app support (lat/lon input + GPS)

Stripe Connect payouts

PostGIS optimization if needed