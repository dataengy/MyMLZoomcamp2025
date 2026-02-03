from fastapi import FastAPI
from pydantic import BaseModel

from config.logging import configure_logging, log

configure_logging()

app = FastAPI(title="MyMLZoomcamp2025 API")


class PredictRequest(BaseModel):
    features: list[float]


class PredictResponse(BaseModel):
    prediction: float


@app.get("/health")
def health() -> dict:
    log.info("Health check requested")
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
def predict(payload: PredictRequest) -> PredictResponse:
    # Placeholder logic until a real model is wired in.
    prediction = float(sum(payload.features))
    log.info("Prediction requested (features={})", len(payload.features))
    return PredictResponse(prediction=prediction)
