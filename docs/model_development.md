# Model Development

Guide for training, evaluating, and deploying ML models.

## Overview

Model development workflow:
1. **Exploration** - EDA in notebooks
2. **Experimentation** - Test different models and features
3. **Training** - Train final model with best parameters
4. **Evaluation** - Assess performance on test data
5. **Deployment** - Save model and integrate with API

## Notebooks

Start with notebooks for exploration and experimentation:

```bash
make jupyter
# Access at http://localhost:8888
```

See [notebooks/README.md](../notebooks/README.md) for templates and best practices.

## Training Script

Training code lives in [`src/training/`](../src/training/).

Run training (from the project root):
```bash
make train
# or, manually:
PYTHONPATH=src uv run python src/training/train.py
```

## Model Registry

Models are saved to [`models/`](../models/):
```
models/
├── model.joblib          # Latest production model
├── model_v1.joblib       # Versioned models
└── model_metadata.json   # Model metadata
```

## Evaluation Reports

Metrics and visualizations are saved to [`.run/reports/`](../.run/reports/):
```
.run/reports/
├── metrics.json          # Model performance metrics
├── confusion_matrix.png  # Classification reports
└── feature_importance.png
```

## Model Versioning

TODO: Implement model versioning strategy (MLflow, DVC, etc.)

## Hyperparameter Tuning

Use notebooks or training scripts with:
- Grid Search
- Random Search
- Optuna
- Ray Tune

Example in notebook:
```python
from sklearn.model_selection import GridSearchCV

param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [10, 20, 30]
}

grid_search = GridSearchCV(
    model, param_grid,
    cv=5, scoring='r2',
    n_jobs=-1
)
grid_search.fit(X_train, y_train)
best_model = grid_search.best_estimator_
```

## Model Deployment

### Save Model

```python
import joblib
from pathlib import Path

MODELS_DIR = Path("models")
MODELS_DIR.mkdir(exist_ok=True)

joblib.dump(model, MODELS_DIR / "model.joblib")
```

### Load in API

See [`src/api/main.py`](../src/api/main.py) for loading model in FastAPI.

### Docker Deployment

Models are copied into Docker image during build. See [`deploy/docker-compose.yml`](../deploy/docker-compose.yml).

## Monitoring

TODO: Add model monitoring (drift detection, performance tracking)

## See Also

- [API Reference](api.md) - Model serving
- [Data Pipeline](data_pipeline.md) - Data preparation
- [Notebooks](../notebooks/README.md) - Experimentation
- [Data Pipeline](data_pipeline.md) - Training orchestration via Dagster
