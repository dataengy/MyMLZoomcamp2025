# Tests

This directory contains the test suites for the project.

## Layout

- `unit/`: fast unit tests for core functionality
- `integration/`: integration tests for data and ML workflows
- `docker/`: container-related tests
- `bash/`: Bats smoke tests for scripts/Justfiles

## Running tests

Run tests from the repo root so relative paths resolve correctly:

```sh
# All tests
python -m pytest tests

# Unit tests only
python -m pytest tests/unit

# Integration tests only
python -m pytest tests/integration

# Docker tests only
python -m pytest tests/docker

# Bats smoke tests (requires bats)
bats tests/bash
```


## Justfile shortcuts

From `tests/`:

```sh
just help
just test
just unit
just integration
just docker
just bats
```

From the repo root:

```sh
just -f tests/Justfile test
```

## Test environment defaults

`conftest.py` sets default values for test environment variables when they are
not already defined. Override any of these to change behavior:

- `RAW_DATA_DIR` (default: `data/raw_test`)
- `PROCESSED_DATA_DIR` (default: `data/processed_test`)
- `DATA_TYPE` (default: `yellow_tripdata`)
- `DATA_YEAR` (default: `2024`)
- `DATA_MONTHS` (default: `1,2,3`)
- `ALLOW_DOWNLOAD` (default: `0`)
- `DATA_SAMPLE` (default: `1`)
- `SAMPLE_SIZE` (default: `500`)
- `OUTPUT_FORMAT` (default: `csv`)
- `MODEL_PATH` (default: `models/model.joblib`)
