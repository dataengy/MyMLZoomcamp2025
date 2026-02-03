from __future__ import annotations

from pathlib import Path

import pytest


@pytest.fixture()
def eval_deps():
    pytest.require_optional("pandas", "sklearn")
    import joblib
    from sklearn.dummy import DummyRegressor

    from training.evaluate import main

    return joblib, DummyRegressor, main


def test_evaluate_writes_metrics(tmp_path: Path, monkeypatch, eval_deps) -> None:
    joblib, DummyRegressor, main = eval_deps
    data_dir = tmp_path / "data" / "processed"
    data_dir.mkdir(parents=True)
    data_path = data_dir / "processed_data.csv"
    data_path.write_text(
        "trip_duration,trip_distance,passenger_count\n600,2.5,1\n900,5.0,2\n300,1.0,1\n"
    )

    model_dir = tmp_path / "models"
    model_dir.mkdir()
    model_path = model_dir / "model.joblib"
    features = ["trip_distance", "passenger_count"]
    model = DummyRegressor(strategy="mean")
    model.fit([[1.0, 1.0], [2.0, 2.0]], [600.0, 900.0])
    joblib.dump(
        {
            "model": model,
            "features": features,
            "target": "trip_duration",
            "model_type": "dummy",
            "params": {},
        },
        model_path,
    )

    output_path = tmp_path / ".run" / "reports" / "evaluation.json"

    monkeypatch.chdir(tmp_path)
    exit_code = main(
        [
            "--data",
            str(data_path),
            "--model",
            str(model_path),
            "--output",
            str(output_path),
        ]
    )

    assert exit_code == 0
    assert output_path.exists()
