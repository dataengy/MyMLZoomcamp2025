# Makefile - Common operations for MyMLZoomcamp2025
# For complex recipes with arguments, see Justfile
# For detailed scripts, see scripts/

.PHONY: all clean setup lint lint-notebooks format format-python format-shell format-yaml format-just format-hooks test test-notebooks test-notebooks-sanitized train serve run-dags streamlit jupyter docker-build docker-up up

# ============================================================================
# Configuration
# ============================================================================

LOG_LEVEL ?= debug
export LOG_LEVEL

# ============================================================================
# Setup and Initialization
# ============================================================================

# Initial project setup (dependencies, git hooks, etc.)
setup:
	./scripts/setup.sh

# Run all checks (lint + test)
all: lint test

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
	pre-commit run --all-files yamllint

# Lint Jupyter notebooks with ruff via nbqa
lint-notebooks:
	./scripts/notebooks/lint_notebooks.sh

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
# Testing
# ============================================================================

# Run unit tests with pytest
test:
	@if ! uv run python -c "import fastapi, pandas, dagster" >/dev/null 2>&1; then \
		echo "Missing test deps. Syncing..."; \
		uv sync --frozen; \
	fi
	uv run pytest -q

# Test notebook execution with nbval
# Note: Can be slow for large notebooks
test-notebooks:
	./scripts/notebooks/test_notebooks.sh

# Check that notebooks have no outputs (sanitized for git)
# This prevents committing notebook outputs that cause merge conflicts
test-notebooks-sanitized:
	./scripts/notebooks/check_sanitized.sh

# ============================================================================
# ML Pipeline
# ============================================================================

# Train ML model
train:
	uv run python src/training/train.py

# ============================================================================
# Services
# ============================================================================

# Start FastAPI server (development mode with hot reload)
serve:
	PYTHONPATH=src uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

# Start Dagster web UI for pipeline management
# Uses 'dg' CLI if available, falls back to 'dagster'
run-dags:
	@mkdir -p .run/dagster
	@if ! uv run python -c "import dagster_webserver" >/dev/null 2>&1; then \
		echo "Missing dagster-webserver. Syncing deps..."; \
		uv sync; \
	fi
	@if uv run python -c "import shutil; raise SystemExit(0 if shutil.which('dg') else 1)" >/dev/null 2>&1; then \
		DAGSTER_HOME=.run/dagster PYTHONPATH=src uv run dg dev -m dags --host 0.0.0.0 --port 3000; \
	else \
		DAGSTER_HOME=.run/dagster PYTHONPATH=src uv run dagster dev -m dags --host 0.0.0.0 --port 3000; \
	fi

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
