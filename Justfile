# Complex + speed-oriented recipes live here.
# Keep Makefile for common ops (lint/test/train/serve/etc.).
# Data loader environment (override on CLI: `just data DATA_SOURCE=...`)

export DATA_SOURCE := ""
export DATA_OUTPUT := ""
export DATA_COLUMNS := ""
export DATA_NROWS := ""
export DATA_FORMAT := ""
export DATA_OUTPUT_FORMAT := ""
export DATA_CACHE_DIR := ""

setup-dev:
    uv sync
    direnv allow && direnv reload
    git remote -v

# Pipeline steps
data:
    @if [ -z "{{ DATA_SOURCE }}" ]; then \
    	echo "Set DATA_SOURCE to a URL or local path. Examples:"; \
    	echo "  just data DATA_SOURCE=data/raw/sample.csv DATA_OUTPUT=data/processed/sample.csv"; \
    	echo "  just data DATA_SOURCE=https://example.com/yellow_tripdata_2024-01.parquet DATA_COLUMNS=tpep_pickup_datetime,tpep_dropoff_datetime,trip_distance,fare_amount DATA_NROWS=100000 DATA_OUTPUT=data/processed/yellow_2024-01.parquet"; \
    	exit 2; \
    fi
    bash -c 'source scripts/utils/Makefile-utils.sh && run_data'

data-download:
    uv run python scripts/data_tools/download_data.py

data-process:
    uv run python scripts/data_tools/process_data.py

data-test:
    uv run python tests/bash/simple_data_test.py

ml-test:
    uv run python tests/bash/simple_ml_test.py

evaluate:
    uv run python src/training/evaluate.py

full-pipeline:
    just data
    make train
    just evaluate
    just deploy-local
    echo "Full pipeline executed"

deploy-local:
    @bash -c 'set -e; \
    if ! command -v docker >/dev/null 2>&1; then \
    	echo "docker not found in PATH"; exit 2; \
    fi; \
    if ! docker compose version >/dev/null 2>&1; then \
    	echo "docker compose not available"; exit 2; \
    fi; \
    if [ ! -f deploy/docker-compose.yml ]; then \
    	echo "deploy/docker-compose.yml not found"; exit 2; \
    fi; \
    docker compose -f deploy/docker-compose.yml up --build api'

test-fast:
    uv run pytest -q
