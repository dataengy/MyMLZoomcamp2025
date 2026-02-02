# MyMLZoomcamp2025

Small ML project scaffold with a FastAPI service, Dagster orchestration stubs, and a data loader script.

## Quick start

1) Create a virtual environment and install deps:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -e .
```

2) Run tests:

```bash
pytest -q
```

Notes:
- API tests require `fastapi` (installed via project deps).
- Orchestration tests require `dagster` (installed via project deps).
- Docker test is skipped unless `DOCKER_TESTS=1` and Docker is available.

## Data loader

Use `scripts/load_data.py` to load datasets like NYC Taxi parquet/csv/json files from a URL or local path.

Examples:

```bash
python scripts/load_data.py \
  --source https://example.com/yellow_tripdata_2024-01.parquet \
  --columns "tpep_pickup_datetime,tpep_dropoff_datetime,trip_distance,fare_amount" \
  --nrows 100000 \
  --output data/processed/yellow_2024-01.parquet
```

```bash
python scripts/load_data.py \
  --source data/raw/sample.csv \
  --output data/processed/sample.csv \
  --show-head
```

## Structure

- `src/api` - FastAPI app
- `src/dags` - Dagster asset definitions
- `src/training` - training placeholder
- `scripts` - utility scripts
- `tests` - test suite
