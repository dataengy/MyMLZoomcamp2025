# Justfile - Detailed project recipes and advanced workflows
# Purpose:
# - Source of truth for task logic: arguments, branching, orchestration, and composition.
# - Keeps complex commands readable and centralized, with heavier logic in `scripts/`.
# - Provides richer ergonomics (args, defaults, aliases) than Make for the repo.
# Usage:
# - Prefer `just <task>` for anything beyond the small wrapper targets in the Makefile.
# - Many tasks accept env vars or args documented inline with each recipe.
# Notes:
# - Add new detailed recipes here; keep Makefile minimal and delegative.
# - Setup helpers live in scripts/setup/Justfile (run with: just -f scripts/setup/Justfile <task>)
# - Keep recipes composable so higher-level targets can chain them predictably.
# - Prefer calling `scripts/` helpers for complex logic to keep recipes readable.
# - Document non-obvious env vars or side effects directly above each recipe.

# ============================================================================
# Configuration
# ============================================================================

# Use bash with strict error handling
set shell := ["bash", "-euo", "pipefail", "-c"]

# Enable verbose logging with TRACE=1
# Example: TRACE=1 just nb-check
TRACE := env_var_or_default("TRACE", "0")

# Logging and orchestration defaults
export LOG_LEVEL := env_var_or_default("LOG_LEVEL", "debug")
export ORCHESTRATOR := env_var_or_default("ORCHESTRATOR", "dagster")

# Conditionally enable bash tracing
_trace := if TRACE == "1" { "set -x;" } else { "" }

# Project paths - centralized for DRY
#todo: store these also in .env.common
SCRIPTS_DIR := "scripts"
NOTEBOOKS_DIR := "notebooks"
NOTEBOOKS_SCRIPTS := SCRIPTS_DIR / "notebooks"
DATA_TOOLS := SCRIPTS_DIR / "data_tools"

# ============================================================================
# Data Pipeline Environment Variables
# Override on CLI: just data DATA_SOURCE=... DATA_OUTPUT=...
# ============================================================================

export DATA_SOURCE := ""
export DATA_OUTPUT := ""
export DATA_COLUMNS := ""
export DATA_NROWS := ""
export DATA_FORMAT := ""
export DATA_OUTPUT_FORMAT := ""
export DATA_CACHE_DIR := ""

# ============================================================================
# Development Setup
# ============================================================================

# Setup development environment (deps, direnv, git)
setup-dev:
    uv sync
    direnv allow && direnv reload
    git remote -v

# Initial project setup (dependencies, git hooks, etc.)
setup:
    ./scripts/setup/setup.sh

# Clean build artifacts and caches
clean:
    rm -rf .pytest_cache .ruff_cache .mypy_cache .cache

# ============================================================================
# Linting and Code Quality
# ============================================================================

# Lint all code (Python, Shell, YAML, Makefile)
lint:
    uv run ruff check .
    pre-commit run --all-files shellcheck
    pre-commit run --all-files checkmake

# Run all pre-commit checks
pre-commit:
    pre-commit run --all-files

# ============================================================================
# Data Pipeline Recipes
# ============================================================================

# Load data from URL or local path with optional filtering
# Usage:
#   just data DATA_SOURCE=data/raw/sample.csv DATA_OUTPUT=data/processed/sample.csv
#   just data DATA_SOURCE=https://example.com/data.parquet DATA_COLUMNS=col1,col2 DATA_NROWS=10000 DATA_OUTPUT=data/processed/data.parquet
#   TRACE=1 just data DATA_SOURCE=...  # Enable verbose logging
data:
    @{{_trace}} \
    if [ -z "{{ DATA_SOURCE }}" ]; then \
    	echo "Set DATA_SOURCE to a URL or local path. Examples:"; \
    	echo "  just data DATA_SOURCE=data/raw/sample.csv DATA_OUTPUT=data/processed/sample.csv"; \
    	echo "  just data DATA_SOURCE=https://example.com/yellow_tripdata_2024-01.parquet DATA_COLUMNS=tpep_pickup_datetime,tpep_dropoff_datetime,trip_distance,fare_amount DATA_NROWS=100000 DATA_OUTPUT=data/processed/yellow_2024-01.parquet"; \
    	exit 2; \
    fi
    @{{_trace}} bash -c 'source scripts/utils/Makefile-utils.sh && run_data'

# Download raw data using download_data.py script
data-download:
    uv run python {{DATA_TOOLS}}/download_data.py

# Process raw data into clean format
data-process:
    uv run python {{DATA_TOOLS}}/process_data.py

# Quick data validation test
data-test:
    uv run python scripts/tests/simple_data_test.py

# Quick ML pipeline test
ml-test:
    uv run python scripts/tests/simple_ml_test.py

# Evaluate trained model performance
evaluate:
    uv run python src/training/evaluate.py

# ============================================================================
# Full Pipeline Execution
# ============================================================================

# Execute complete ML pipeline: data -> train -> evaluate -> deploy
full-pipeline:
    just data
    make train
    just evaluate
    just deploy-local
    echo "✓ Full pipeline executed successfully!"

# ============================================================================
# Deployment
# ============================================================================

# Deploy API locally using Docker Compose
deploy-local:
    {{SCRIPTS_DIR}}/setup/docker-check.sh
    docker compose -f deploy/docker-compose.yml up --build api

# ============================================================================
# Testing
# ============================================================================

# Verify config/.env matches config/.env.demo
env-check:
    uv run python scripts/setup/env-check.py

# Run unit tests with pytest
test:
    @if ! uv run python -c "import fastapi, pandas, dagster" >/dev/null 2>&1; then \
    	echo "Missing test deps. Syncing..."; \
    	uv sync --frozen; \
    fi
    uv run pytest -q

# Fast test run (quiet mode)
test-fast:
    uv run pytest -q

# Full test run (unit + notebooks + QA + CI parity checks)
test-all: test test-notebooks test-notebooks-sanitized qa-all-project github-ci-test gitlab-ci-test
    @echo "✓ Test (all) completed successfully!"

# Full test run in parallel (best-effort speedup).
test-all-parallel:
    @{{_trace}} \
    set +e; \
    (just test) & t1=$$!; \
    (just test-notebooks) & t2=$$!; \
    (just test-notebooks-sanitized) & t3=$$!; \
    (just qa-all-project) & t4=$$!; \
    (just github-ci-test) & t5=$$!; \
    (just gitlab-ci-test) & t6=$$!; \
    wait $$t1; s1=$$?; \
    wait $$t2; s2=$$?; \
    wait $$t3; s3=$$?; \
    wait $$t4; s4=$$?; \
    wait $$t5; s5=$$?; \
    wait $$t6; s6=$$?; \
    if [ $$s1 -ne 0 ] || [ $$s2 -ne 0 ] || [ $$s3 -ne 0 ] || [ $$s4 -ne 0 ] || [ $$s5 -ne 0 ] || [ $$s6 -ne 0 ]; then \
        exit 1; \
    fi; \
    echo "✓ Test (all, parallel) completed successfully!"

# ============================================================================
# Doctor / Maintenance
# ============================================================================

# Summary project health check
doctor:
    ./scripts/doctor/loc-02-project-health-check.sh

# Codex skills sanity check (dry-run install)
codex-check:
    scripts/codex/install_local_skills.sh --dry-run

# Run legacy GitHub push doctor (interactive)
github-push *args:
    just -f scripts/doctor/Justfile github-push {{args}}

# Sync branch with remote and push (auto-stash + rebase supported)
sync-push *args:
    just -f scripts/doctor/Justfile sync-push {{args}}

# Run project health check (supports --fix/--verbose)
health-check *args:
    just -f scripts/doctor/Justfile health-check {{args}}

# Verify Docker engine/compose access
docker-check *args:
    just -f scripts/doctor/Justfile docker-check {{args}}

# Run tests with safe defaults (or pass a custom command)
test-safe *args:
    just -f scripts/doctor/Justfile test-safe {{args}}

# Check local web tool URL responsiveness (Dagster UI, etc.)
web-tool-check *args:
    just -f scripts/doctor/Justfile web-tool-check {{args}}

# ============================================================================
# Notebook Management
# All notebook operations use scripts in scripts/notebooks/
# ============================================================================

# Lint notebooks with ruff via nbqa
lint-notebooks:
    {{NOTEBOOKS_SCRIPTS}}/lint_notebooks.sh

# Format notebooks with ruff via nbqa
format-notebooks:
    {{NOTEBOOKS_SCRIPTS}}/format_notebooks.sh

# Test notebook execution with pytest + nbval
# Note: Can be slow for notebooks with heavy computation
test-notebooks:
    {{NOTEBOOKS_SCRIPTS}}/test_notebooks.sh

# Check that notebooks are sanitized (no outputs/execution counts)
# Prevents merge conflicts from committed notebook outputs
test-notebooks-sanitized:
    {{NOTEBOOKS_SCRIPTS}}/check_sanitized.sh

# Strip all outputs from notebooks (prepare for commit)
strip-notebooks:
    {{NOTEBOOKS_SCRIPTS}}/strip_notebooks.sh

# Full notebook QA (lint + format + tests + sanitized + strip)
notebooks-qa: lint-notebooks format-notebooks test-notebooks test-notebooks-sanitized strip-notebooks
    @echo "✓ Notebook QA completed successfully!"

# Run all notebook checks (lint + sanitized check)
notebooks-check: lint-notebooks test-notebooks-sanitized
    @echo "✓ All notebook checks passed!"

# ============================================================================
# Notebook Workflow Aliases (short commands)
# ============================================================================

# Alias: lint notebooks (shortcut for lint-notebooks)
nb-lint: lint-notebooks

# Alias: format notebooks (shortcut for format-notebooks)
nb-fmt: format-notebooks

# Alias: test notebooks (shortcut for test-notebooks)
nb-test: test-notebooks

# Alias: check notebooks (lint + sanitized)
nb-check: notebooks-check

# Alias: strip notebook outputs
nb-strip: strip-notebooks

# ============================================================================
# QA Aggregation
# ============================================================================

# Data/ML QA (sanity tests)
data-ml-qa: data-test ml-test
    @echo "✓ Data/ML QA completed successfully!"

# Run all QA checks (lint + tests + notebook QA + data/ML sanity tests).
# This is the canonical QA entry point used by Makefile's `qa-all`.
qa-all-project: notebooks-qa data-ml-qa test-fast
    just lint
    just test
    @echo "✓ QA (all) completed successfully!"

# ============================================================================
# CI Parity Helpers
# ============================================================================

# Run the GitHub Actions CI checks locally (best-effort parity).
github-ci-test:
    uv run ruff check .
    {{NOTEBOOKS_SCRIPTS}}/lint_notebooks.sh
    uv run --with yamllint yamllint .
    uv run pytest -v
    {{NOTEBOOKS_SCRIPTS}}/check_sanitized.sh
    {{NOTEBOOKS_SCRIPTS}}/test_notebooks.sh || true

# Run the GitLab CI checks locally (best-effort parity).
gitlab-ci-test:
    uv run ruff check .
    uv run ruff format --check .
    pre-commit run --all-files shellcheck
    pre-commit run --all-files shfmt
    uv run --with yamllint yamllint .
    {{NOTEBOOKS_SCRIPTS}}/lint_notebooks.sh
    uv run pytest -v --cov=src --cov-report=term --cov-report=xml
    {{NOTEBOOKS_SCRIPTS}}/check_sanitized.sh
    {{NOTEBOOKS_SCRIPTS}}/test_notebooks.sh || true

# ============================================================================
# Code Formatting
# ============================================================================

# Format all code (Python, Shell, YAML, Just, hooks)
format: format-python format-shell format-yaml format-just format-hooks

# Format Python code with ruff
format-python:
    uv run ruff format .

# Format shell scripts with shfmt
format-shell:
    pre-commit run --all-files shfmt

# Format YAML files
format-yaml:
    pre-commit run --all-files yamlfmt

# Format Justfile
format-just:
    pre-commit run --all-files just-fmt

# Run general formatting hooks (EOF, trailing whitespace)
format-hooks:
    pre-commit run --all-files end-of-file-fixer
    pre-commit run --all-files trailing-whitespace

# ============================================================================
# ML Pipeline
# ============================================================================

# Train ML model
train:
    PYTHONPATH=src uv run python src/training/train.py

# ============================================================================
# Services
# ============================================================================

# Start FastAPI server (development mode with hot reload)
serve:
    PYTHONPATH=src uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

# Start Dagster web UI for pipeline management
# Uses 'dg' CLI if available, falls back to 'dagster'
dagster:
    @./scripts/dagster/start_dagster.sh

# Orchestrator entrypoint (select via ORCHESTRATOR=dagster)
run-dags:
    @case "${ORCHESTRATOR}" in \
    	dagster) just dagster ;; \
    	*) echo "Unknown orchestrator: $(ORCHESTRATOR)"; echo "Supported: dagster"; exit 1 ;; \
    esac

# Start Streamlit UI for model interaction
streamlit:
    STREAMLIT_DATA_PATH=data/processed uv run streamlit run src/ui/streamlit_app.py --server.port 8501

# Start Jupyter Lab for notebook development
jupyter:
    uv run jupyter lab --ip=0.0.0.0 --port 8888 --no-browser

# ============================================================================
# Docker
# ============================================================================

# Build Docker image
docker-build:
    docker build -t mymlzoomcamp2025:latest .

# Start all services with Docker Compose
docker-up:
    docker compose up --build

# Alias for docker-up
up: docker-up

# ============================================================================
# Common Aggregations
# ============================================================================

# Run all checks (lint + test) in parallel for faster feedback.
all-lint-test:
    @{{_trace}} \
    set +e; \
    (just lint) & lint_pid=$$!; \
    (just test) & test_pid=$$!; \
    wait $$lint_pid; lint_status=$$?; \
    wait $$test_pid; test_status=$$?; \
    if [ $$lint_status -ne 0 ] || [ $$test_status -ne 0 ]; then \
        exit 1; \
    fi

# Backwards-compatible alias.
all: all-lint-test

# ============================================================================
# Makefile Mirrors (invoke Make from Just)
# ============================================================================

# Makefile wrapper: make setup
make-setup:
    make setup

# Makefile wrapper: make env-check
make-env-check:
    make env-check

# Makefile wrapper: make doctor
make-doctor:
    make doctor

# Makefile wrapper: make clean
make-clean:
    make clean

# Makefile wrapper: make lint
make-lint:
    make lint

# Makefile wrapper: make format
make-format:
    make format

# Makefile wrapper: make test
make-test:
    make test

# Makefile wrapper: make train
make-train:
    make train

# Makefile wrapper: make serve
make-serve:
    make serve

# Makefile wrapper: make dagster
make-dagster:
    make dagster

# Makefile wrapper: make run-dags
make-run-dags:
    make run-dags

# Makefile wrapper: make streamlit
make-streamlit:
    make streamlit

# Makefile wrapper: make jupyter
make-jupyter:
    make jupyter

# Makefile wrapper: make docker-up
make-docker-up:
    make docker-up

# Makefile wrapper: make qa-all
make-qa-all:
    make qa-all

# Makefile wrapper: make all
make-all:
    make all

# ============================================================================
# Utility Shortcuts
# ============================================================================

# Install Codex skills (local repo) via scripts/codex/Justfile
codex-install-skills *args:
    just -f scripts/codex/Justfile install-skills {{args}}
