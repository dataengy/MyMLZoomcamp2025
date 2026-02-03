# Makefile - Common operations for MyMLZoomcamp2025
# Purpose:
# - Provide familiar `make <target>` entry points for the most common tasks.
# - Keep the surface area small so contributors don't need to learn Just immediately.
# - Delegate all detailed logic, arguments, and multi-step flows to `Justfile`.
# Usage:
# - Use `make test`, `make lint`, `make setup`, etc. for quick, standard workflows.
# - For advanced options (flags, args, orchestration), use `just <task>`.
# Notes:
# - This file should remain a thin wrapper layer; avoid adding complex logic here.
# - Target `_` ensures `just` is present so the wrappers stay reliable across fresh machines.
# - When adding new targets, prefer delegating to `just` unless the target is trivial.
# - Keep shell snippets minimal and non-interactive to avoid surprising CI behavior.

.PHONY: _ all clean setup env-check doctor lint format test train serve docker-up qa-all \
	dagster run-dags streamlit jupyter

# ============================================================================
# Common Targets (thin wrappers around Justfile)
# ============================================================================

# For more specific operations, use `just ...` directly (examples):
# - Notebooks: `just lint-notebooks`, `just test-notebooks`, `just nb-check`
# - Orchestration/UI: `just dagster`, `just run-dags`, `just streamlit`, `just jupyter`
# - Data/ML: `just data`, `just data-process`, `just ml-test`, `just evaluate`
# - Docker/Deploy: `just docker-build`, `just deploy-local`, `just full-pipeline`
#
# Detailed Justfile commands aligned with the targets in this Makefile:
# - setup: `just setup` (full environment bootstrap)
# - env-check: `just env-check` (verify .env vs .env.demo)
# - doctor: `just doctor` (project health checks)
# - clean: `just clean` (remove caches/artifacts)
# - lint: `just lint` (ruff + pre-commit checks)
# - format: `just format` (ruff format + hooks)
# - test: `just test` (pytest with deps guard)
# - train: `just train` (run training pipeline)
# - serve: `just serve` (start FastAPI dev server)
# - docker-up: `just docker-up` (compose up --build)
# - dagster/run-dags/streamlit/jupyter: corresponding `just <task>`
# - qa-all: `just qa-all-project` (full QA suite)
# - all: `just all-lint-test` (lint + test)

# Ensure `just` is installed before delegating to Justfile recipes.
# This stays silent when already installed to avoid noisy output in CI.
_:
	source ./scripts/setup/setup.sh && ensure_just

# Bootstrap project dependencies and tooling.
setup: _
	just setup

# Validate that config/.env matches config/.env.demo.
env-check: _
	just env-check

# Run the project health check suite.
doctor: _
	just doctor

# Remove caches and temporary build artifacts.
clean: _
	just clean

# Run all linters for code and configs.
lint: _
	just lint

# Format code and config files.
format: _
	just format

# Run unit tests with the default test runner.
test: _
	just test

# Train the default model pipeline.
train: _
	just train

# Launch the API server in development mode.
serve: _
	just serve

# Build and start services with Docker Compose.
docker-up: _
	just docker-up

## Start Dagster web UI.
#dagster: _
#	just dagster

# Run pipeline orchestration entrypoint.
run-dags: _
	just run-dags

# Start Streamlit app.
streamlit: _
	just streamlit

# Start Jupyter Lab.
jupyter: _
	just jupyter

# Run the full QA suite (lint + tests + notebook checks).
qa-all: _
	just qa-all-project

# Run the common "lint + test" aggregation.
all: _
	just all-lint-test
