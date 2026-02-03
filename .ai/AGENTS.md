# Agent Notes

This repo is a small ML project scaffold with FastAPI, Dagster, Streamlit, and data tooling. Keep edits minimal and aligned with existing scripts.

## Project Overview
ML Zoomcamp-style repo with FastAPI, Dagster, Docker, and scripts for data prep.

## Ground Rules
- Use `make` for common ops (lint/test/train/serve/etc.)
- Use `just` for complex or speed-oriented workflows (data pipeline, fast tests)
- Prefer `uv run ...` for Python commands to respect the lockfile
- Keep scripts in [`scripts/`](../scripts/) and tests in [`tests/`](../tests/) aligned with the README
- Keep scripts ASCII-only
- Prefer [`scripts/utils.sh`](../scripts/utils.sh) helpers for shell scripts

## Layout
- [`src/api`](../src/api) - FastAPI app
- [`src/dags`](../src/dags) - Dagster assets
- [`src/ui`](../src/ui) - Streamlit app
- [`src/training`](../src/training) - training/evaluation
- [`scripts/data_tools`](../scripts/data_tools) - download/process/load data
- [`tests/bash`](../tests/bash) - simple data/ml test runners
- [`config/`](../config/) - env and config templates
- [`notebooks/`](../notebooks/) - Jupyter notebooks for R&D and experimentation
- [`docs/`](../docs/) - detailed project documentation
- [`.ai/`](.) - AI agent artifacts and documentation

## Common Commands

### Setup
- [`./scripts/setup.sh`](../scripts/setup.sh) - install tooling + deps
- `ALLOW_DIRENV=1 ./scripts/setup.sh` - setup with direnv allow
- `make setup` - alternative setup command

### Development
- Lint/format/test: `make lint`, `make format`, `make test`
- Fast tests: `just test-fast`
- Tests: `PYTHONPATH=src pytest -q`
- Train/evaluate: `make train`, `just evaluate`

### Services
- Serve: `make serve`
- Orchestration UI: `make run-dags`
- Streamlit/Jupyter: `make streamlit`, `make jupyter`

### Docker
- `make docker-build`, `make docker-up`
- [`./docker-start.sh`](../docker-start.sh) or `docker compose -f deploy/docker-compose.yml up --build`

## Data Pipeline (Justfile)
- Load data: `just data DATA_SOURCE=... DATA_OUTPUT=...`
- Download/process: `just data-download`, `just data-process`
- Sanity tests: `just data-test`, `just ml-test`
- Full pipeline: `just full-pipeline`

## Environment
- Python 3.13 (managed via `uv`)
- Env vars live in [`config/.env`](../config/.env) (copy from [`config/.env.demo`](../config/.env.demo))
- Logging uses [`config/config.yml`](../config/config.yml) and `LOG_LEVEL` in [`config/.env`](../config/.env)
- `direnv` optional; run `ALLOW_DIRENV=1 ./scripts/setup.sh` if you want it to call `direnv allow`

## Testing Notes
- Docker test is opt-in: set `DOCKER_TESTS=1` to run [`tests/test_docker_container.py`](../tests/test_docker_container.py)
- Some tests rely on optional deps (pandas/duckdb) and will skip if missing
- API tests require `fastapi` (installed via project deps)
- Orchestration tests require `dagster` (installed via project deps)