from typing import List

from fastapi import FastAPI
from pydantic import BaseModel

from config.logging import configure_logging
from loguru import logger

configure_logging()

app = FastAPI(title="MyMLZoomcamp2025 API")


class PredictRequest(BaseModel):
    features: List[float]


class PredictResponse(BaseModel):
    prediction: float


@app.get("/health")
def health() -> dict:
    logger.info("Health check requested")
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
def predict(payload: PredictRequest) -> PredictResponse:
    # Placeholder logic until a real model is wired in.
    prediction = float(sum(payload.features))
    logger.info("Prediction requested (features={})", len(payload.features))
    return PredictResponse(prediction=prediction)
