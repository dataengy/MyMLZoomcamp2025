from pathlib import Path

import pytest


@pytest.fixture(scope="module")
def api_deps():
    pytest.require_optional("joblib", "fastapi", "sklearn")
    import joblib
    from fastapi.testclient import TestClient
    from sklearn.linear_model import LinearRegression

    from api.main import app

    return app, joblib, TestClient, LinearRegression


def test_health(api_deps) -> None:
    app, _, TestClient, _ = api_deps
    client = TestClient(app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_predict(tmp_path: Path, monkeypatch, api_deps) -> None:
    app, joblib, TestClient, LinearRegression = api_deps
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
