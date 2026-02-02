import pytest

pytest.importorskip("fastapi")
from fastapi.testclient import TestClient

from api.main import app

client = TestClient(app)


def test_health() -> None:
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_predict() -> None:
    response = client.post("/predict", json={"features": [1.0, 2.5, 3.5]})
    assert response.status_code == 200
    assert response.json() == {"prediction": 7.0}
