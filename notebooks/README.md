# Notebooks

Jupyter notebooks for research, development, and experimentation.

## Structure

- [`01_exploratory_data_analysis.ipynb`](01_exploratory_data_analysis.ipynb) - Initial data exploration and visualization
- [`02_feature_engineering.ipynb`](02_feature_engineering.ipynb) - Feature creation and transformation experiments
- [`03_model_experiments.ipynb`](03_model_experiments.ipynb) - Model training, comparison, and hyperparameter tuning
- [`04_model_evaluation.ipynb`](04_model_evaluation.ipynb) - Model performance analysis and visualization
- [`templates/`](templates/) - Notebook templates for common tasks

## Getting Started

### Launch Jupyter Lab

**Local:**
```bash
make jupyter
```

**Docker:**
```bash
docker compose -f ../deploy/docker-compose.yml up jupyter
# or
../docker-start.sh jupyter
# or (interactive menu)
../docker-start.sh --menu
```

Access at: `http://localhost:8888`

### Configuration

- Jupyter token is set via `JUPYTER_TOKEN` in [`../config/.env`](../config/.env)
- Empty token disables authentication (development only)
- Data is mounted from [`../data/`](../data/)
- Models are saved to [`../models/`](../models/)
- Reports are saved to [`../reports/`](../reports/)

## Notebook Guidelines

### File Naming

Use numbered prefixes for sequential analysis:
- `01_`, `02_`, `03_` - Main analysis sequence
- `exp_` - Experimental notebooks (not part of main flow)
- `draft_` - Work in progress
- `archive_` - Completed experiments (move to `archive/`)

### Best Practices

1. **Clear structure**: Use markdown headers to organize sections
2. **Document assumptions**: Explain why you made specific choices
3. **Reproducible**: Set random seeds, document dependencies
4. **Clean outputs**: Clear outputs before committing (use `pre-commit` hooks)
5. **Export key findings**: Save important results to [`../reports/`](../reports/)
6. **Modular code**: Move reusable code to [`../src/`](../src/)

### Common Tasks

**Load data:**
```python
import pandas as pd
from pathlib import Path

DATA_DIR = Path("../data")
df = pd.read_parquet(DATA_DIR / "processed" / "dataset.parquet")
```

**Save results:**
```python
import json
from pathlib import Path

REPORTS_DIR = Path("../reports")
REPORTS_DIR.mkdir(exist_ok=True)

results = {"metric": value}
with open(REPORTS_DIR / "experiment_results.json", "w") as f:
    json.dump(results, f, indent=2)
```

**Save models:**
```python
import joblib
from pathlib import Path

MODELS_DIR = Path("../models")
MODELS_DIR.mkdir(exist_ok=True)

joblib.dump(model, MODELS_DIR / "model.joblib")
```

## Data Sources

See [`../scripts/data_tools/`](../scripts/data_tools/) for data loading utilities:
- [`download_data.py`](../scripts/data_tools/download_data.py) - Download datasets
- [`process_data.py`](../scripts/data_tools/process_data.py) - Clean and transform data
- [`load_data.py`](../scripts/data_tools/load_data.py) - Generic data loader

## References

- Project documentation: [`../docs/`](../docs/)
- API reference: [`../docs/api.md`](../docs/api.md)
- Training pipeline: [`../src/training/`](../src/training/)
- Data pipeline: [`../src/dags/`](../src/dags/)
