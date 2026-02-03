from pathlib import Path

import pytest

pytest.importorskip("joblib")
pytest.importorskip("fastapi")
pytest.importorskip("sklearn")

import joblib
from fastapi.testclient import TestClient
from sklearn.linear_model import LinearRegression

from api.main import app


def test_health() -> None:
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_predict(tmp_path: Path, monkeypatch) -> None:
    model_path = tmp_path / "model.joblib"
    features = ["trip_distance", "passenger_count"]
    X = [[1.0, 1.0], [2.0, 2.0], [3.0, 4.0]]
    y = [2.0, 4.0, 7.0]
    model = LinearRegression(fit_intercept=False)
    model.fit(X, y)
    joblib.dump(
        {
            "model": model,
            "features": features,
            "target": "trip_duration",
            "model_type": "linear_regression",
            "params": {},
        },
        model_path,
    )

    monkeypatch.setenv("MODEL_PATH", str(model_path))
    client = TestClient(app)
    response = client.post(
        "/predict",
        json={"features": {"trip_distance": 2.0, "passenger_count": 3.0}},
    )
    assert response.status_code == 200
    assert response.json()["prediction"] == pytest.approx(5.0)
