# MyMLZoomcamp2025

Small ML project scaffold with a FastAPI service, Dagster pipeline, Docker support, and data scripts.

## Problem statement

Predict NYC taxi trip duration (seconds) from trip metadata. This is a regression task trained on NYC TLC
Yellow Taxi trip records. Features are generated from pickup/dropoff timestamps, distances, passenger
counts, and location IDs.

Default dataset: NYC TLC Yellow Taxi (parquet). The pipeline can download data or generate a synthetic
sample if downloads are disabled.

## Quick start

1) Install tooling + deps (direnv optional, just required for Makefile wrappers, uv, Python) and sync the lockfile:

```bash
./scripts/setup/setup.sh
```

Or use the wrapper:
```bash
make setup
```

If you want setup to call `direnv allow`, run:

```bash
ALLOW_DIRENV=1 ./scripts/setup/setup.sh
```

2) Run tests:

```bash
make test
```

Notes:
- API tests require `fastapi` (installed via project deps).
- Orchestration tests require `dagster` (installed via project deps).
- Docker test is skipped unless `DOCKER_TESTS=1` and Docker is available.
- Environment variables live in [`config/.env`](config/.env) (sync from [`config/.env.demo`](config/.env.demo)).
- Use `scripts/setup/env-render.py --interactive` to update `config/.env`, and `scripts/setup/env-check.py` to verify sync.
- Logging is configured via [`config/config.yml`](config/config.yml) and `LOG_LEVEL` in [`config/.env`](config/.env).
- Set `LOG_FORMAT=short` for compact emoji logs (`yy/mm/dd hh:mm:ss` + emoji + place + message).
- Setup utilities are documented in [`scripts/setup/README.md`](scripts/setup/README.md) (see also `scripts/setup/Justfile`).
- Dagster asset details live in [`src/dags/README.md`](src/dags/README.md).

## Jupyter Notebooks

### Testing and Linting

```bash
# Lint notebooks with ruff
just nb-lint

# Check notebooks are sanitized (no outputs)
just nb-check

# Test notebook execution (can be slow)
just nb-test

# Strip outputs from all notebooks
just nb-strip

# Format notebooks
just nb-fmt

# Run all notebook checks
just nb-check
```

**Important:** Always strip notebook outputs before committing to prevent merge conflicts:
```bash
just nb-strip
git add notebooks/
git commit -m "Update notebooks"
```

See [`docs/notebook-testing.md`](docs/notebook-testing.md) for detailed documentation.

### Notebook Tools

- **nbqa** - Run ruff linter/formatter on notebooks
- **nbval** - Test notebook execution with pytest
- **nbstripout** - Auto-strip outputs on commit
- **pre-commit hooks** - Automatic linting and sanitization

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
- Dagster UI is started via `make dagster`, which calls `scripts/dagster/start_dagster.sh`.
- You can override defaults: `scripts/dagster/start_dagster.sh --host 127.0.0.1 --port 3000 --module dags`.

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

The [`docker-start.sh`](docker-start.sh) script provides a convenient interface for managing Docker services.
For full details, see [`docker-start.md`](docker-start.md).

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

Virtual environment:
- The project uses a single virtual environment at `./.run/.venv` (no root `.venv`).

## Data scripts

Use the scripts below for data setup and sanity checks:

- [`scripts/data_tools/download_data.py`](scripts/data_tools/download_data.py) - download NYC Taxi parquet files.
- [`scripts/data_tools/process_data.py`](scripts/data_tools/process_data.py) - clean + feature engineer the NYC Taxi data.
- [`tests/bash/simple_data_test.py`](tests/bash/simple_data_test.py) - generate synthetic data and run a basic pipeline check.
- [`tests/bash/simple_ml_test.py`](tests/bash/simple_ml_test.py) - train a tiny linear model on processed synthetic data.

Use [`scripts/data_tools/load_data.py`](scripts/data_tools/load_data.py) to load datasets like NYC Taxi parquet/csv/json files from a URL or local path.

Pipeline defaults:
- Raw data dir: `data/raw`
- Processed data dir: `data/processed`
- Model path: `models/model.joblib`
- Metrics: `reports/metrics.json` and `reports/evaluation.json`

Dagster environment overrides:
- `ALLOW_DOWNLOAD=1` to fetch NYC TLC data when raw files are missing.
- `DATA_YEAR`, `DATA_MONTHS` (comma-separated), `DATA_TYPE` to control downloads.
- `PROCESSED_DATA_DIR`, `MODEL_PATH`, `OUTPUT_FORMAT`, `SAMPLE_SIZE` for custom paths and sampling.

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
- [`scripts/claude`](scripts/claude) - Claude Code helpers (context, skill install, Justfile)
- [`scripts/codex`](scripts/codex) - Codex CLI helpers (skill install, Justfile)
- [`tests/`](tests/) - test suite
- [`notebooks/`](notebooks/) - Jupyter notebooks for R&D and experimentation (see [notebooks/README.md](notebooks/README.md))
- [`docs/`](docs/) - detailed project documentation (see [docs/README.md](docs/README.md))
- [`.ai/`](.ai/) - AI agent artifacts and documentation (see [`.ai/AGENTS.md`](.ai/AGENTS.md))

## Documentation

Comprehensive documentation is available in [`docs/`](docs/):

- [**API Reference**](docs/api.md) - FastAPI endpoints and usage
- [**Development Guide**](docs/development.md) - Local setup, testing, and contributions
- [**Data Pipeline**](docs/data_pipeline.md) - Data processing and validation
- [**Model Development**](docs/model_development.md) - Training and evaluation
- [**Notebooks Guide**](notebooks/README.md) - Jupyter notebooks for experimentation

## Make vs Just

This repo uses both a Makefile (common workflows) and a Justfile (advanced and wrapper workflows). See the combined guide:

- [**Makefile + Justfile guide**](docs/make-just.md)
