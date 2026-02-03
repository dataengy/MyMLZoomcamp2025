# Justfile - Complex recipes with arguments
# For simple common operations, see Makefile
# Complex logic lives in scripts/ directory

# ============================================================================
# Configuration
# ============================================================================

# Use bash with strict error handling
set shell := ["bash", "-euo", "pipefail", "-c"]

# Enable verbose logging with TRACE=1
# Example: TRACE=1 just nb-check
TRACE := env_var_or_default("TRACE", "0")

# Conditionally enable bash tracing
_trace := if TRACE == "1" { "set -x;" } else { "" }

# Project paths - centralized for DRY
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
    uv run python tests/bash/simple_data_test.py

# Quick ML pipeline test
ml-test:
    uv run python tests/bash/simple_ml_test.py

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

# Fast test run (quiet mode)
test-fast:
    uv run pytest -q

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

# Run all notebook checks (lint + sanitized check)
notebooks-check: lint-notebooks test-notebooks-sanitized
    @echo "✓ All notebook checks passed!"

# ============================================================================
# Notebook Workflow Aliases (short commands)
# ============================================================================

# Alias: lint notebooks
nb-lint: lint-notebooks

# Alias: format notebooks
nb-fmt: format-notebooks

# Alias: test notebooks
nb-test: test-notebooks

# Alias: check notebooks (lint + sanitized)
nb-check: notebooks-check

# Alias: strip notebook outputs
nb-strip: strip-notebooks

# ============================================================================
# QA Aggregation
# ============================================================================

# Run all QA checks (lint + tests + notebook QA + data/ML sanity tests)
qa-all-project: lint-notebooks format-notebooks test-notebooks test-notebooks-sanitized strip-notebooks data-test ml-test test-fast
    make lint
    make test
    @echo "✓ QA (all) completed successfully!"
