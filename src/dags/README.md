# Dagster Assets

This package defines the Dagster assets for the ML pipeline.

## Assets

- `raw_data` - download or synthesize raw taxi data.
- `prepared_data` - clean/feature-engineer raw data.
- `trained_model` - train and serialize the best model.
- `evaluation_report` - evaluate the model and write metrics.

## Environment

Assets read configuration from `config/.env` (loaded via `config.env.load_env`).
The loader runs `scripts/setup/env-check.py` before reading `.env`, so keep
`config/.env` synced with `config/.env.demo`.

Required variables include:

- `RAW_DATA_DIR`, `PROCESSED_DATA_DIR`
- `DATA_TYPE`, `DATA_YEAR`, `DATA_MONTHS`
- `ALLOW_DOWNLOAD`, `DATA_SAMPLE`, `SAMPLE_SIZE`, `OUTPUT_FORMAT`
- `MODEL_PATH`

## Running

```bash
# Dagster UI (uses the repo defaults)
make run-dags

# Direct execution with dg
DAGSTER_HOME=.run/dagster PYTHONPATH=src uv run dg dev -m dags
```

Outputs land under `REPORTS_DIR` (see `config/.env`).
