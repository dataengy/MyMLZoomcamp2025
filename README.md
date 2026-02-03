# MyMLZoomcamp2025

Small ML project scaffold with a FastAPI service, Dagster stubs, Docker support, and data scripts.

## Quick start

1) Install tooling + deps (direnv optional, just optional, uv, Python) and sync the lockfile:

```bash
./scripts/setup.sh
```

If you want setup to call `direnv allow`, run:

```bash
ALLOW_DIRENV=1 ./scripts/setup.sh
```

2) Run tests:

```bash
make test
```

Notes:
- API tests require `fastapi` (installed via project deps).
- Orchestration tests require `dagster` (installed via project deps).
- Docker test is skipped unless `DOCKER_TESTS=1` and Docker is available.
- Environment variables live in `config/.env` (copy from `config/.env.demo`).
- Logging is configured via `config/config.yml` and `LOG_LEVEL` in `config/.env`.

## Local services

Run the API:

```bash
make serve
```

Run the Dagster UI + daemon:

```bash
make run-dags
```

Run Streamlit:

```bash
make streamlit
```

Run Jupyter Lab:

```bash
make jupyter
```

Notes:
- Streamlit reads from `data/processed` by default; set `STREAMLIT_DATA_PATH` if needed.
- Set `JUPYTER_TOKEN` in `config/.env` to secure Jupyter (empty token disables auth).

Docker equivalents:

```bash
docker compose up api
docker compose up dagster
docker compose up streamlit
docker compose up jupyter
```

Or use the helper:

```bash
./docker-run.sh
```

## Dev tooling

Pre-commit hooks (requires `pre-commit` installed):

```bash
pre-commit install
pre-commit run --all-files
```

## Data scripts

Use the scripts below for data setup and sanity checks:

- `scripts/download_data.py` - download NYC Taxi parquet files.
- `scripts/process_data.py` - clean + feature engineer the NYC Taxi data.
- `scripts/simple_data_test.py` - generate synthetic data and run a basic pipeline check.
- `scripts/simple_ml_test.py` - train a tiny linear model on processed synthetic data.

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
- `src/ui` - Streamlit app
- `src/training` - training placeholder
- `scripts` - utility scripts
- `tests` - test suite

## Make/Just targets

Common targets:

- `make data-download` / `just data-download`
- `make data-process` / `just data-process`
- `make data-test` / `just data-test`
- `make ml-test` / `just ml-test`
- `make run-dags` / `just run-dags`
- `make streamlit` / `just streamlit`
- `make jupyter` / `just jupyter`
- `make up` / `just up`
