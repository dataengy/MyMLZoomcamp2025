from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd

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


def train_mean_baseline(data_path: Path, target: str = "trip_duration") -> dict:
    if not data_path.exists():
        raise FileNotFoundError(f"Data file not found: {data_path}")

    df = _load_data(data_path)
    log.info("Loaded training data (rows={})", len(df))
    if target not in df.columns:
        raise ValueError(f"Missing target column: {target}")

    target_values = df[target]
    mean_value = float(target_values.mean())
    mae = float((target_values - mean_value).abs().mean())
    rmse = float(((target_values - mean_value) ** 2).mean() ** 0.5)

    return {
        "model": {"type": "mean_baseline", "target": target, "target_mean": mean_value},
        "metrics": {"mae": mae, "rmse": rmse, "samples": int(len(df))},
        "features": [col for col in df.columns if col != target],
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Train a baseline model.")
    parser.add_argument(
        "--data",
        type=Path,
        default=Path("data/processed/processed_data.csv"),
        help="Path to processed data",
    )
    parser.add_argument(
        "--model-out",
        type=Path,
        default=Path("models/model.json"),
        help="Output path for model metadata",
    )
    parser.add_argument(
        "--metrics-out",
        type=Path,
        default=REPORTS_DIR / "metrics.json",
        help="Output path for training metrics",
    )

    args = parser.parse_args(argv)

    log.info("Starting training run")
    log.debug("Args: {}", args)
    result = train_mean_baseline(args.data)

    args.model_out.parent.mkdir(parents=True, exist_ok=True)
    args.metrics_out.parent.mkdir(parents=True, exist_ok=True)

    args.model_out.write_text(json.dumps(result["model"], indent=2))
    args.metrics_out.write_text(json.dumps(result["metrics"], indent=2))
    log.info("Saved model to {}", args.model_out)
    log.info("Saved metrics to {}", args.metrics_out)
    return 0


if __name__ == "__main__":
    raise SystemExit(log.catch(main)())
