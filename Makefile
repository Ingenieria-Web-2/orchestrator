SHELL := /usr/bin/env bash

.PHONY: help build up down ps logs test-docker test-users test-recipes lint clean

help:
	@echo "Makefile targets:"
	@echo "  make build          Build all service images (docker compose build)"
	@echo "  make up             Start compose stack (database + services)"
	@echo "  make down           Stop and remove compose stack (volumes)")
	@echo "  make ps             Show compose ps"
	@echo "  make logs           Tail logs for services"
	@echo "  make test-docker    Run pytest inside service containers (containerized tests)"
	@echo "  make test-users     Run user_service tests in container"
	@echo "  make test-recipes   Run recipe_service tests in container"
	@echo "  make lint           Run linters (locally configured)"
	@echo "  make clean          Remove local test DBs and temporary artifacts"

build:
	docker compose build --parallel

up:
	docker compose up -d user_db recipe_db

down:
	docker compose down -v

ps:
	docker compose ps

logs:
	docker compose logs --tail=200 -f

test-docker: build up
	@echo "Running tests inside containers..."
	@mkdir -p user_service/reports recipe_service/reports
	docker compose run --rm -v "$(PWD)/user_service/reports:/usr/src/user_service/reports" user_service python -m pytest --junitxml=reports/users-results.xml -v
	docker compose run --rm -v "$(PWD)/recipe_service/reports:/usr/src/recipe_service/reports" recipe_service python -m pytest --junitxml=reports/recipes-results.xml -v

test-users:
	@mkdir -p user_service/reports
	docker compose run --rm -v "$(PWD)/user_service/reports:/usr/src/user_service/reports" user_service python -m pytest --junitxml=reports/users-results.xml -v

test-recipes:
	@mkdir -p recipe_service/reports
	docker compose run --rm -v "$(PWD)/recipe_service/reports:/usr/src/recipe_service/reports" recipe_service python -m pytest --junitxml=reports/recipes-results.xml -v

lint:
	@echo "No linter configured in Makefile. Please run your linter (pylint/flake8) manually or add commands here."

clean:
	@echo "Cleaning test artifacts..."
	rm -f user_service/app/test_db.sqlite || true
	rm -f recipe_service/app/test_db.sqlite || true
