# Orchestrator for all services for DolceIQ

This repository contains a docker-compose orchestrator for the multiple microservices used by the DolceIQ project.

## Members

- Andrés Felipe Moreno Durango
- Santiago Olaya Rojas

## Contents

- `docker-compose.yaml` - top-level compose file that wires the API gateway, services, and databases.
- `api_gateway/` - nginx config used to route and validate requests.
- `user_service/`, `recipe_service/` - individual microservices.
- `Makefile` - convenience tasks to build images, start the stack, and run tests inside containers.
- `.github/workflows/ci-docker.yml` - containerized CI workflow that builds images and runs tests inside the containers.

## Quickstart (local development)

Requirements:
- Docker & Docker Compose
- GNU Make (optional, `make` targets use docker-compose)

Run tests inside the containers (recommended — mirrors CI):

```
make test-docker
```

Stop and remove the stack:

```
make down
```

## License

MIT License.
