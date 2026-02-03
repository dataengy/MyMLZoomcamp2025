from __future__ import annotations

import argparse
import json
from pathlib import Path

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.linear_model import ElasticNet
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score
from sklearn.model_selection import GridSearchCV, train_test_split
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from config.logging import configure_logging, log
from config.paths import REPORTS_DIR

configure_logging()


def _infer_format(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix == ".parquet":
        return "parquet"
    if suffix == ".csv":
        return "csv"
    raise ValueError(f"Unsupported data format: {suffix}")


def _load_data(path: Path) -> pd.DataFrame:
    fmt = _infer_format(path)
    if fmt == "parquet":
        return pd.read_parquet(path)
    if fmt == "csv":
        return pd.read_csv(path)
    raise ValueError(f"Unsupported data format: {fmt}")


def _compute_metrics(y_true, y_pred) -> dict:
    return {
        "mae": float(mean_absolute_error(y_true, y_pred)),
        "rmse": float(mean_squared_error(y_true, y_pred, squared=False)),
        "r2": float(r2_score(y_true, y_pred)),
        "samples": int(len(y_true)),
    }


def _fit_model(name: str, pipeline: Pipeline, param_grid: dict, X_train, y_train) -> dict:
    search = GridSearchCV(
        pipeline,
        param_grid=param_grid,
        cv=3,
        scoring="neg_mean_absolute_error",
        n_jobs=-1,
    )
    search.fit(X_train, y_train)
    log.info("Best {} params: {}", name, search.best_params_)
    return {"name": name, "estimator": search.best_estimator_, "params": search.best_params_}


def train_model(
    data_path: Path,
    model_out: Path,
    metrics_out: Path,
    target: str = "trip_duration",
    test_size: float = 0.2,
    random_state: int = 42,
) -> dict:
    if not data_path.exists():
        raise FileNotFoundError(f"Data file not found: {data_path}")

    df = _load_data(data_path)
    log.info("Loaded training data (rows={})", len(df))
    if target not in df.columns:
        raise ValueError(f"Missing target column: {target}")

    features = [col for col in df.columns if col != target]
    X = df[features]
    y = df[target]

    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=test_size, random_state=random_state
    )

    elastic_pipeline = Pipeline(
        [
            ("scaler", StandardScaler()),
            ("model", ElasticNet(max_iter=5000, random_state=random_state)),
        ]
    )
    elastic_params = {
        "model__alpha": [0.01, 0.1, 1.0],
        "model__l1_ratio": [0.1, 0.5, 0.9],
    }

    rf_pipeline = Pipeline(
        [
            (
                "model",
                RandomForestRegressor(
                    random_state=random_state,
                    n_estimators=200,
                    n_jobs=-1,
                ),
            )
        ]
    )
    rf_params = {
        "model__n_estimators": [150, 300],
        "model__max_depth": [None, 12, 24],
        "model__min_samples_leaf": [1, 2],
    }

    candidates = [
        _fit_model("elastic_net", elastic_pipeline, elastic_params, X_train, y_train),
        _fit_model("random_forest", rf_pipeline, rf_params, X_train, y_train),
    ]

    best = None
    best_score = float("inf")
    for candidate in candidates:
        preds = candidate["estimator"].predict(X_test)
        mae = mean_absolute_error(y_test, preds)
        if mae < best_score:
            best_score = mae
            best = candidate

    if best is None:
        raise RuntimeError("Model training failed to produce a candidate.")

    train_preds = best["estimator"].predict(X_train)
    test_preds = best["estimator"].predict(X_test)
    metrics = {
        "train": _compute_metrics(y_train, train_preds),
        "test": _compute_metrics(y_test, test_preds),
    }

    model_bundle = {
        "model": best["estimator"],
        "features": features,
        "target": target,
        "model_type": best["name"],
        "params": best["params"],
    }

    model_out.parent.mkdir(parents=True, exist_ok=True)
    metrics_out.parent.mkdir(parents=True, exist_ok=True)
    joblib.dump(model_bundle, model_out)

    metrics_payload = {
        "model_type": best["name"],
        "params": best["params"],
        "metrics": metrics,
        "features": features,
        "target": target,
        "samples": {"train": int(len(y_train)), "test": int(len(y_test))},
    }
    metrics_out.write_text(json.dumps(metrics_payload, indent=2))

    log.info("Saved model to {}", model_out)
    log.info("Saved metrics to {}", metrics_out)
    return metrics_payload


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Train ML models and select the best.")
    parser.add_argument(
        "--data",
        type=Path,
        default=Path("data/processed/processed_data.csv"),
        help="Path to processed data",
    )
    parser.add_argument(
        "--model-out",
        type=Path,
        default=Path("models/model.joblib"),
        help="Output path for serialized model bundle",
    )
    parser.add_argument(
        "--metrics-out",
        type=Path,
        default=REPORTS_DIR / "metrics.json",
        help="Output path for training metrics",
    )
    parser.add_argument(
        "--target",
        default="trip_duration",
        help="Target column name",
    )
    parser.add_argument(
        "--test-size",
        type=float,
        default=0.2,
        help="Test split ratio",
    )
    parser.add_argument(
        "--random-state",
        type=int,
        default=42,
        help="Random state for reproducibility",
    )

    args = parser.parse_args(argv)

    log.info("Starting training run")
    log.debug("Args: {}", args)
    train_model(
        data_path=args.data,
        model_out=args.model_out,
        metrics_out=args.metrics_out,
        target=args.target,
        test_size=args.test_size,
        random_state=args.random_state,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(log.catch(main)())
