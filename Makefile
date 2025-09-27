SHELL := /usr/bin/env bash

.PHONY: help build up down ps logs test-docker test-users test-recipes lint clean

help:
	@echo "Makefile targets:"
	@echo "  make test-docker    Run pytest inside service containers (containerized tests)"
	@echo "  make test-users     Run user_service tests in container"
	@echo "  make test-recipes   Run recipe_service tests in container"

test-docker:
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