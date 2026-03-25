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
