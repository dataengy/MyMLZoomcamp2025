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
- Environment variables live in [`config/.env`](config/.env) (copy from [`config/.env.demo`](config/.env.demo)).
- Logging is configured via [`config/config.yml`](config/config.yml) and `LOG_LEVEL` in [`config/.env`](config/.env).

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
- Streamlit reads from [`data/processed`](data/processed) by default; set `STREAMLIT_DATA_PATH` if needed.
- Set `JUPYTER_TOKEN` in [`config/.env`](config/.env) to secure Jupyter (empty token disables auth).

Docker equivalents:

```bash
docker compose -f deploy/docker-compose.yml up api
docker compose -f deploy/docker-compose.yml up dagster
docker compose -f deploy/docker-compose.yml up streamlit
docker compose -f deploy/docker-compose.yml up jupyter
```

Or use the helper [`docker-start.sh`](docker-start.sh):

```bash
# CLI mode (direct service start)
./docker-start.sh api
./docker-start.sh -d streamlit
./docker-start.sh -i api

# Interactive menu mode
./docker-start.sh --menu
```

## Docker helper script

The [`docker-start.sh`](docker-start.sh) script provides a convenient interface for managing Docker services:

**CLI mode:**
```bash
./docker-start.sh [options] [service]

Options:
  -b, --build           Build before starting (default)
  --no-build            Skip build
  -n, --no-cache        Build with --no-cache
  -d, --detach          Run in background
  -i, --interactive     Attach to a service with exec
  -m, --menu            Interactive menu mode
  -c, --command CMD     Command to run (with --interactive)
  -h, --help            Show this help
```

**Interactive menu mode:**
```bash
./docker-start.sh --menu
```

The menu provides options to:
- Start services (foreground/background)
- Open interactive shells in containers
- Build services (with/without cache)
- Stop all services
- View logs
- And more

## Dev tooling

Pre-commit hooks (requires `pre-commit` installed):

```bash
pre-commit install
pre-commit run --all-files
```

## Data scripts

Use the scripts below for data setup and sanity checks:

- [`scripts/data_tools/download_data.py`](scripts/data_tools/download_data.py) - download NYC Taxi parquet files.
- [`scripts/data_tools/process_data.py`](scripts/data_tools/process_data.py) - clean + feature engineer the NYC Taxi data.
- [`tests/bash/simple_data_test.py`](tests/bash/simple_data_test.py) - generate synthetic data and run a basic pipeline check.
- [`tests/bash/simple_ml_test.py`](tests/bash/simple_ml_test.py) - train a tiny linear model on processed synthetic data.

Use [`scripts/data_tools/load_data.py`](scripts/data_tools/load_data.py) to load datasets like NYC Taxi parquet/csv/json files from a URL or local path.

Examples:

```bash
python scripts/data_tools/load_data.py \
  --source https://example.com/yellow_tripdata_2024-01.parquet \
  --columns "tpep_pickup_datetime,tpep_dropoff_datetime,trip_distance,fare_amount" \
  --nrows 100000 \
  --output data/processed/yellow_2024-01.parquet
```

```bash
python scripts/data_tools/load_data.py \
  --source data/raw/sample.csv \
  --output data/processed/sample.csv \
  --show-head
```

## Structure

- [`src/api`](src/api) - FastAPI app
- [`src/dags`](src/dags) - Dagster asset definitions
- [`src/ui`](src/ui) - Streamlit app
- [`src/training`](src/training) - training placeholder
- [`scripts/`](scripts/) - utility scripts
- [`tests/`](tests/) - test suite
- [`notebooks/`](notebooks/) - Jupyter notebooks for R&D and experimentation
- [`docs/`](docs/) - detailed project documentation
- [`.ai/`](.ai/) - AI agent artifacts and documentation (see [`.ai/AGENTS.md`](.ai/AGENTS.md))

## Make vs Just

Use the [`Makefile`](Makefile) for the main, common ops. Use the [`Justfile`](Justfile) for more complex or speed-oriented workflows.

### Makefile (common ops)

Common targets:

- `make setup`
- `make lint`
- `make format`
- `make test`
- `make train`
- `make serve`
- `make run-dags`
- `make streamlit`
- `make jupyter`
- `make docker-build`
- `make docker-up` / `make up`

### Justfile (complex / fast ops)

- `just setup-dev`
- `just data` (requires `DATA_SOURCE`, optional `DATA_COLUMNS`, `DATA_NROWS`, `DATA_OUTPUT`)
- `just data-download`
- `just data-process`
- `just data-test`
- `just ml-test`
- `just evaluate`
- `just full-pipeline`
- `just test-fast`
