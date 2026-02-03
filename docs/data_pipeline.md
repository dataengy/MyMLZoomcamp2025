# Data Pipeline

Documentation for data ingestion, processing, and validation.

## Overview

The data pipeline consists of:
1. **Ingestion** - Download/load raw data
2. **Processing** - Clean, transform, and feature engineering
3. **Validation** - Data quality checks
4. **Storage** - Save processed data

## Data Tools

Located in [`scripts/data_tools/`](../scripts/data_tools/):

### Download Data

[`download_data.py`](../scripts/data_tools/download_data.py) - Download NYC Taxi parquet files

```bash
python scripts/data_tools/download_data.py
```

### Process Data

[`process_data.py`](../scripts/data_tools/process_data.py) - Clean and feature engineer data

```bash
python scripts/data_tools/process_data.py
```

### Load Data

[`load_data.py`](../scripts/data_tools/load_data.py) - Generic data loader for parquet/csv/json

```bash
python scripts/data_tools/load_data.py \
  --source https://example.com/data.parquet \
  --columns "col1,col2,col3" \
  --nrows 100000 \
  --output data/processed/data.parquet
```

## Data Directory Structure

```
data/
├── raw/          # Raw, unprocessed data
├── processed/    # Cleaned and transformed data
└── external/     # External reference data
```

## Orchestration

Data pipeline is orchestrated with Dagster. See [orchestration.md](orchestration.md) for details.

## Data Validation

TODO: Add data validation strategy (Great Expectations, Pandera, etc.)

## See Also

- [Orchestration](orchestration.md) - Dagster pipeline
- [Model Development](model_development.md) - Using processed data for training
- [Notebooks](../notebooks/README.md) - Exploratory data analysis
