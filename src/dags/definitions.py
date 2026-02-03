from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path

import pandas as pd
from dagster import Definitions, asset, define_asset_job

from config.env import load_env, require_env
from config.paths import REPORTS_DIR
from scripts.data_tools.download_data import download_files, resolve_months
from scripts.data_tools.process_data import process_data
from training.evaluate import evaluate_model
from training.train import train_model

load_env()


@dataclass(frozen=True)
class TrainingArtifacts:
    model_path: str
    metrics_path: str
    evaluation_path: str


def _env_bool(name: str) -> bool:
    value = require_env(name)
    return value.lower() in {"1", "true", "yes", "y"}


def _parse_months(value: str) -> list[int]:
    return [int(item.strip()) for item in value.split(",") if item.strip()]


def _write_synthetic_raw(output_dir: Path) -> Path:
    output_dir.mkdir(parents=True, exist_ok=True)
    path = output_dir / "synthetic_taxi.csv"
    if path.exists():
        return path

    now = pd.Timestamp.utcnow().floor("h")
    rows = 50
    data = {
        "tpep_pickup_datetime": [now - pd.Timedelta(minutes=15 * i) for i in range(rows)],
        "tpep_dropoff_datetime": [now - pd.Timedelta(minutes=15 * i - 10) for i in range(rows)],
        "passenger_count": [1 + (i % 3) for i in range(rows)],
        "trip_distance": [0.5 + (i % 10) * 0.7 for i in range(rows)],
        "fare_amount": [5.0 + (i % 10) * 2.5 for i in range(rows)],
        "PULocationID": [132 + (i % 5) for i in range(rows)],
        "DOLocationID": [138 + (i % 5) for i in range(rows)],
    }
    pd.DataFrame(data).to_csv(path, index=False)
    return path


@asset
def raw_data() -> dict:
    raw_dir = Path(require_env("RAW_DATA_DIR"))
    data_type = require_env("DATA_TYPE")
    year = int(require_env("DATA_YEAR"))
    months = _parse_months(require_env("DATA_MONTHS"))
    allow_download = _env_bool("ALLOW_DOWNLOAD")
    sample = _env_bool("DATA_SAMPLE")

    existing_files = list(raw_dir.glob("*.parquet")) + list(raw_dir.glob("*.csv"))
    if existing_files:
        return {"status": "ready", "files": [str(path) for path in existing_files]}

    if allow_download:
        selected_months = resolve_months(months, sample)
        downloaded, skipped = download_files(
            data_type=data_type,
            year=year,
            months=selected_months,
            output_dir=raw_dir,
            force=False,
        )
        return {
            "status": "downloaded",
            "files": [str(path) for path in downloaded + skipped],
        }

    synthetic_path = _write_synthetic_raw(raw_dir)
    return {"status": "synthetic", "files": [str(synthetic_path)]}


@asset
def prepared_data(raw_data: dict) -> dict:
    _ = raw_data
    input_dir = Path(require_env("RAW_DATA_DIR"))
    output_dir = Path(require_env("PROCESSED_DATA_DIR"))
    sample_size_raw = require_env("SAMPLE_SIZE")
    sample_size_int = int(sample_size_raw) if sample_size_raw else None
    output_format = require_env("OUTPUT_FORMAT")

    result = process_data(
        input_dir=input_dir,
        output_dir=output_dir,
        sample_size=sample_size_int,
        output_format=output_format,
    )
    result["status"] = "prepared"
    return result


@asset
def trained_model(prepared_data: dict) -> TrainingArtifacts:
    data_path = Path(prepared_data["processed_path"])
    model_path = Path(require_env("MODEL_PATH"))
    metrics_path = REPORTS_DIR / "metrics.json"
    train_model(
        data_path=data_path,
        model_out=model_path,
        metrics_out=metrics_path,
    )
    evaluation_path = REPORTS_DIR / "evaluation.json"
    return TrainingArtifacts(
        model_path=str(model_path),
        metrics_path=str(metrics_path),
        evaluation_path=str(evaluation_path),
    )


@asset
def evaluation_report(prepared_data: dict, trained_model: TrainingArtifacts) -> dict:
    data_path = Path(prepared_data["processed_path"])
    output_path = Path(trained_model.evaluation_path)
    metrics = evaluate_model(data_path, Path(trained_model.model_path))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(metrics, indent=2))
    metrics["status"] = "evaluated"
    return metrics


training_job = define_asset_job("training_job")

defs = Definitions(
    assets=[raw_data, prepared_data, trained_model, evaluation_report],
    jobs=[training_job],
)
