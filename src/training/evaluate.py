from __future__ import annotations

import argparse
import json
from pathlib import Path

import pandas as pd


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


def evaluate_mean_baseline(data_path: Path, model_path: Path) -> dict:
    if not data_path.exists():
        raise FileNotFoundError(f"Data file not found: {data_path}")
    if not model_path.exists():
        raise FileNotFoundError(f"Model file not found: {model_path}")

    df = _load_data(data_path)
    model = json.loads(model_path.read_text())
    target = model.get("target", "trip_duration")
    if target not in df.columns:
        raise ValueError(f"Missing target column: {target}")

    mean_value = float(model["target_mean"])
    target_values = df[target]
    mae = float((target_values - mean_value).abs().mean())
    rmse = float(((target_values - mean_value) ** 2).mean() ** 0.5)

    return {
        "mae": mae,
        "rmse": rmse,
        "samples": int(len(df)),
        "model_type": model.get("type", "unknown"),
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Evaluate a baseline model.")
    parser.add_argument(
        "--data",
        type=Path,
        default=Path("data/processed/processed_data.parquet"),
        help="Path to processed data",
    )
    parser.add_argument(
        "--model",
        type=Path,
        default=Path("models/model.json"),
        help="Path to model metadata",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("reports/evaluation.json"),
        help="Output path for evaluation metrics",
    )
    args = parser.parse_args(argv)

    metrics = evaluate_mean_baseline(args.data, args.model)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(metrics, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
