# Orchestrator for all services for DolceIQ

This repository contains a docker-compose orchestrator and multiple microservices used by the DolceIQ project. It includes helper scripts, tests, and a CI workflow that runs the service test suites inside containers to replicate the local environment.

## Members

- Andrés Felipe Moreno Durango
- Santiago Olaya Rojas

## Contents

- `docker-compose.yaml` - top-level compose file that wires the API gateway, services, and databases.
- `api_gateway/` - nginx config used to route and validate requests.
- `user_service/`, `recipe_service/` - individual microservices (each with its own `app/`, `requirements.txt`, and Dockerfile).
- `Makefile` - convenience tasks to build images, start the stack, and run tests inside containers.
- `.github/workflows/ci-docker.yml` - containerized CI workflow that builds images and runs tests inside the containers.
- `tools/nginx_auth_check.sh` - helper script with curl examples for the gateway auth flow.

## Quickstart (local development)

Requirements:
- Docker & Docker Compose
- GNU Make (optional, `make` targets use docker-compose)

Start the stack (databases only):

```
make build
make up
```

Run tests inside the containers (recommended — mirrors CI):

```
make test-docker
```

Stop and remove the stack:

```
make down
```

## Running tests locally (without Docker)

You can run tests in a local virtual environment. See individual service `requirements.txt` files and create a venv per service:

```
python -m venv .venv
source .venv/bin/activate
pip install -r user_service/requirements.txt
pip install -r recipe_service/requirements.txt
pytest -q
```

Note: The repository includes several tests that expect to run inside the service context. For exact parity with CI, prefer `make test-docker`.

## CI (GitHub Actions) — containerized tests

This repository includes `.github/workflows/ci-docker.yml` which:
- Builds the service images using `docker compose build` (no dependency installs during `up`).
- Starts DB services and waits for readiness.
- Runs tests using `python -m pytest` inside the built containers.
- Uploads JUnit XML reports and container logs as workflow artifacts and tears down the compose stack.

Why use GitHub Actions services (containerized CI)?
- Reproducible environment: Tests run in the same container image that you build and deploy; this avoids discrepancies between local dev and CI.
- Dependencies baked into images: Faster test runs in CI when you rely on pre-built images and avoid installing dependencies on each CI run.
- Service orchestration: The CI workflow can start DBs and other services via docker-compose, so integration tests that need Postgres or networked services behave the same as locally.
- Easier debugging: Uploaded logs and JUnit XML artifacts make it straightforward to inspect failures from CI runs.

Tradeoffs: containerized CI is slower than native pytest in CI but gives higher fidelity when your app behavior depends on the container runtime.

## Next steps & suggestions

- Consider adding Alembic migrations for schema evolution (both services currently call `Base.metadata.create_all` in main). 
- Add a small linting step and a formatter (black/ruff/pylint) to the CI workflow.
- Use a secret manager for production secrets (this repo keeps a `.env` for local development).

## How to debug CI failures locally

1. Reproduce the CI build locally using `make build` and `make up`.
2. Run the tests in the same container the CI uses:

```
docker compose run --rm user_service python -m pytest -q
```

3. Upload logs or artifacts from the failing service to inspect further.

## License

This repository includes service-specific licenses in each subfolder. See each folder for details.

## Makefile targets

The included `Makefile` exposes a few convenience commands to help during development:

- `make build` - builds all service images in parallel using `docker compose build --parallel`.
- `make up` - starts the database services (`user_db`, `recipe_db`) in the background.
- `make down` - stops and removes the compose stack.
- `make test-docker` - runs both service test suites inside their respective containers and stores reports under `reports/`.
- `make test-users` / `make test-recipes` - run tests for a single service in its container.
- `make logs` - tails logs for all services.
- `make clean` - removes images and cleanup artifacts (use with caution).

Use `make <target>` from the repository root. These targets call `docker compose` to ensure you run tests in the same environment as CI.

