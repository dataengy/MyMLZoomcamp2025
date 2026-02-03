from __future__ import annotations

import argparse
import json
from pathlib import Path

import joblib
import pandas as pd
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

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


def evaluate_model(data_path: Path, model_path: Path) -> dict:
    if not data_path.exists():
        raise FileNotFoundError(f"Data file not found: {data_path}")
    if not model_path.exists():
        raise FileNotFoundError(f"Model file not found: {model_path}")

    df = _load_data(data_path)
    model_bundle = joblib.load(model_path)
    target = model_bundle.get("target", "trip_duration")
    features = model_bundle.get("features")
    if target not in df.columns:
        raise ValueError(f"Missing target column: {target}")
    if not features:
        raise ValueError("Model bundle missing feature list.")

    X = df[features]
    y = df[target]
    preds = model_bundle["model"].predict(X)
    metrics = _compute_metrics(y, preds)

    log.info("Evaluation complete (rows={})", len(df))
    return {
        "model_type": model_bundle.get("model_type", "unknown"),
        "params": model_bundle.get("params", {}),
        "metrics": metrics,
        "target": target,
        "features": features,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Evaluate a trained model.")
    parser.add_argument(
        "--data",
        type=Path,
        default=Path("data/processed/processed_data.csv"),
        help="Path to processed data",
    )
    parser.add_argument(
        "--model",
        type=Path,
        default=Path("models/model.joblib"),
        help="Path to model bundle",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=REPORTS_DIR / "evaluation.json",
        help="Output path for evaluation metrics",
    )
    args = parser.parse_args(argv)

    log.info("Starting evaluation")
    metrics = evaluate_model(args.data, args.model)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(metrics, indent=2))
    log.info("Saved evaluation metrics to {}", args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(log.catch(main)())
