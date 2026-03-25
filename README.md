# GardenMarket

A marketplace platform connecting local gardeners and farmers with consumers. Users can list and sell plants, produce, seeds, and cuttings, browse products by location, manage distribution center pickups, and participate in a gardening community.

## Tech Stack

- **Backend:** Django 5 / Django REST Framework with JWT authentication
- **Database:** PostgreSQL 16 (SQLite fallback for development)
- **Cache / Broker:** Redis 7
- **Task Queue:** Celery (worker + beat scheduler)
- **Object Storage:** MinIO (S3-compatible)
- **API Docs:** drf-spectacular (OpenAPI)
- **Payments:** Stripe
- **Frontend:** Static HTML/CSS/JS

## Project Structure

```
gardenMarket/
├── backend/
│   ├── config/          # Django settings, URLs, WSGI/ASGI, Celery
│   ├── accounts/        # Custom user model, registration, JWT auth
│   ├── gardens/         # Gardener profiles, plant profiles, listings
│   ├── market/          # Cart, orders, Stripe checkout
│   ├── logistics/       # Distribution centers, geocoding
│   ├── sensors/         # IoT sensor devices and readings
│   ├── mediahub/        # Community posts and photos
│   └── moderation/      # User reports, admin audit logs
├── frontend/            # Static HTML/CSS/JS pages
├── docker/              # Dockerfile
├── docs/                # API examples
├── docker-compose.yml
└── Makefile
```

## Getting Started

### Prerequisites

- Docker and Docker Compose

### Environment Configuration

Create a `.env` file in the project root. The Docker Compose stack reads this file for all services (`web`, `worker`, `beat`).

Below is a reference of all supported variables. Variables marked with a default can be omitted for local development.

#### Required for production, recommended to set for local dev

| Variable | Description | Default |
|---|---|---|
| `DJANGO_SECRET_KEY` | Django secret key. **Must** be changed in production. | `unsafe-change-me` |
| `DATABASE_URL` | PostgreSQL connection string, e.g. `postgres://user:pass@host:5432/dbname` | `sqlite:///db.sqlite3` |

#### Django

| Variable | Description | Default |
|---|---|---|
| `DJANGO_DEBUG` | Set to `1` to enable debug mode | `0` |
| `DJANGO_ALLOWED_HOSTS` | Comma-separated allowed hosts | `*` |
| `DJANGO_CSRF_TRUSTED_ORIGINS` | Comma-separated trusted origins for CSRF | _(empty)_ |
| `TIME_ZONE` | Application timezone | `America/Denver` |

#### Redis / Celery

| Variable | Description | Default |
|---|---|---|
| `CELERY_BROKER_URL` | Redis URL for Celery broker | `redis://redis:6379/1` |
| `CELERY_RESULT_BACKEND` | Redis URL for Celery results | `redis://redis:6379/2` |
| `REDIS_URL` | Fallback Redis URL (used if the above are not set) | _(none)_ |

#### S3 / MinIO (object storage)

When all four required S3 variables are set, file uploads use S3 storage. Otherwise files are stored on the local filesystem.

MinIO credentials in `docker-compose.yml` are derived from `S3_ACCESS_KEY` and `S3_SECRET_KEY` (defaulting to `minioadmin` / `minioadmin`).

| Variable | Description | Default |
|---|---|---|
| `S3_ENDPOINT_URL` | S3 endpoint, e.g. `http://minio:9000` | _(none)_ |
| `S3_ACCESS_KEY` | S3 / MinIO access key | _(none)_ |
| `S3_SECRET_KEY` | S3 / MinIO secret key | _(none)_ |
| `S3_BUCKET_NAME` | S3 bucket name | _(none)_ |
| `S3_REGION_NAME` | S3 region | `us-east-1` |

#### Geocoding

| Variable | Description | Default |
|---|---|---|
| `GEOCODING_PROVIDER` | Geocoding service (`nominatim`, etc.) | `nominatim` |
| `GEOCODING_API_KEY` | API key for the geocoding provider | _(empty)_ |

#### Payments (Stripe)

| Variable | Description | Default |
|---|---|---|
| `STRIPE_SECRET_KEY` | Stripe API secret key | _(empty)_ |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret | _(empty)_ |
| `STRIPE_CURRENCY` | Currency code for Stripe charges | `usd` |
| `TAX_RATE` | Tax rate as a decimal (e.g. `0.08` for 8%) | `0.0` |

#### Email

| Variable | Description | Default |
|---|---|---|
| `EMAIL_BACKEND` | Django email backend | `django.core.mail.backends.console.EmailBackend` |
| `DEFAULT_FROM_EMAIL` | Default sender address | `no-reply@gardenmarket.local` |

#### Miscellaneous

| Variable | Description | Default |
|---|---|---|
| `SENSORS_INGEST_RATE_LIMIT_PER_MIN` | Max sensor readings per device per minute | `60` |
| `LISTING_LOW_STOCK_THRESHOLD` | Stock count that triggers low-stock warnings | `2` |

#### Minimal `.env` example

```env
# Django
DJANGO_SECRET_KEY=change-me-to-a-random-string
DJANGO_DEBUG=1

# Database — point at an external Postgres, or use the optional local db profile
DATABASE_URL=postgres://garden:garden@host.docker.internal:5432/garden

# S3 / MinIO — enables file uploads through MinIO
S3_ENDPOINT_URL=http://minio:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_NAME=garden-media
```

### Running the Stack

```bash
# Start all services (redis, minio, web, worker, beat)
make up

# If you need a local Postgres container as well:
docker compose --profile localdb up -d

# Run migrations
make migrate

# Create an admin account
make superuser

# Tail logs
make logs
```

The API is available at `http://localhost:8000`. The MinIO console is at `http://localhost:9002`.

### Optional: Local PostgreSQL

The `db` service uses the `localdb` Docker Compose profile and is not started by default. If you have an external Postgres instance, point `DATABASE_URL` at it. To use the bundled container instead:

```bash
docker compose --profile localdb up -d
# Then set in .env:
# DATABASE_URL=postgres://garden:garden@db:5432/garden
```

### Running Tests

```bash
make test
```

### Useful Make Targets

| Command | Description |
|---|---|
| `make up` | Start all containers in detached mode |
| `make down` | Stop all containers |
| `make logs` | Tail container logs |
| `make bash` | Open a shell in the web container |
| `make migrate` | Run Django migrations |
| `make superuser` | Create a Django superuser |
| `make test` | Run the test suite with pytest |

## API Documentation

Once the stack is running, interactive API docs are available at:

- **Schema:** `http://localhost:8000/schema/`

See [`docs/api_examples.md`](docs/api_examples.md) for example requests covering registration, listings, orders, and more.
