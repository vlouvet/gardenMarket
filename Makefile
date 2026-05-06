SHELL := /bin/bash

up:
	docker compose up -d

down:
	docker compose down

logs:
	docker compose logs -f

bash:
	docker compose exec web bash

makemigrations:
	docker compose exec web python manage.py makemigrations

migrate:
	docker compose exec web python manage.py makemigrations
	docker compose exec web python manage.py migrate

superuser:
	docker compose exec web python manage.py createsuperuser

seed:
	docker compose exec web python manage.py seed_data

init: migrate superuser

test:
	docker compose exec web pytest

# Wipe all volumes (DB, MinIO), bring the stack back up, run migrations and
# seed_data, and ensure the MinIO bucket is publicly readable. Use this
# before a live demo to start from a known state.
demo-reset:
	docker compose down -v
	docker compose up -d
	@echo "Waiting for web to come up..."
	@for i in $$(seq 1 60); do \
		docker compose ps web --format '{{.Status}}' 2>/dev/null | grep -q healthy && break; \
		sleep 1; \
	done
	docker compose exec web python manage.py migrate --noinput
	docker compose exec web python manage.py seed_data
	@echo "Configuring MinIO bucket for public reads..."
	@docker run --rm --network gardenmarket_default --entrypoint sh \
		-e MC_HOST_local=http://minioadmin:minioadmin@minio:9000 minio/mc:latest \
		-c "mc mb -p local/garden-media >/dev/null; mc anonymous set download local/garden-media >/dev/null"
	@echo "Demo ready. Open http://localhost:8881"
	@echo "  Gardener: gardener@example.com / changeme"
	@echo "  Buyer:    buyer@example.com / changeme"

# Run the Playwright smoke suite against the running stack.
e2e:
	docker compose --profile tests run --rm frontend-tests
