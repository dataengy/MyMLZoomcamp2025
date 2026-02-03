from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path

import joblib
import pandas as pd
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from config.logging import configure_logging, log

configure_logging()

app = FastAPI(title="MyMLZoomcamp2025 API")


class PredictRequest(BaseModel):
    features: dict[str, float]


class PredictResponse(BaseModel):
    prediction: float


@lru_cache(maxsize=1)
def _load_model_bundle(model_path: Path) -> dict:
    if not model_path.exists():
        raise FileNotFoundError(f"Model not found: {model_path}")
    return joblib.load(model_path)


@app.get("/health")
def health() -> dict:
    log.info("Health check requested")
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
def predict(payload: PredictRequest) -> PredictResponse:
    model_path = Path(os.getenv("MODEL_PATH", "models/model.joblib"))
    try:
        model_bundle = _load_model_bundle(model_path)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc

    features = model_bundle.get("features", [])
    if not features:
        raise HTTPException(status_code=500, detail="Model bundle missing feature list.")

    missing = [name for name in features if name not in payload.features]
    if missing:
        raise HTTPException(
            status_code=400,
            detail=f"Missing required features: {', '.join(missing)}",
        )

    row = {name: payload.features[name] for name in features}
    X = pd.DataFrame([row])
    prediction = float(model_bundle["model"].predict(X)[0])
    log.info("Prediction requested (features={})", len(features))
    return PredictResponse(prediction=prediction)
