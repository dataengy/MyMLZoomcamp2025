from __future__ import annotations

from dataclasses import dataclass

from dagster import Definitions, asset, define_asset_job


@dataclass(frozen=True)
class TrainingArtifacts:
    model_path: str
    metrics_path: str


@asset
def raw_data() -> dict:
    """Stub raw data ingestion."""
    return {"status": "placeholder", "rows": 0}


@asset
def prepared_data(raw_data: dict) -> dict:
    """Stub feature prep step."""
    return {"status": "placeholder", "source": raw_data}


@asset
def trained_model(prepared_data: dict) -> TrainingArtifacts:
    """Stub training step."""
    _ = prepared_data
    return TrainingArtifacts(
        model_path="models/model.joblib", metrics_path="reports/metrics.json"
    )


@asset
def evaluation_report(trained_model: TrainingArtifacts) -> dict:
    """Stub evaluation step."""
    return {"status": "placeholder", "artifacts": trained_model}


training_job = define_asset_job("training_job")

defs = Definitions(
    assets=[raw_data, prepared_data, trained_model, evaluation_report],
    jobs=[training_job],
)
