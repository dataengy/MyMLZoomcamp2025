from typing import List

from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="MyMLZoomcamp2025 API")


class PredictRequest(BaseModel):
    features: List[float]


class PredictResponse(BaseModel):
    prediction: float


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
def predict(payload: PredictRequest) -> PredictResponse:
    # Placeholder logic until a real model is wired in.
    prediction = float(sum(payload.features))
    return PredictResponse(prediction=prediction)
