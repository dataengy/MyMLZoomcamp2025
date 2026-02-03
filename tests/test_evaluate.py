from __future__ import annotations

import json
from pathlib import Path

import pytest

pytest.importorskip("pandas")

from training.evaluate import main


def test_evaluate_writes_metrics(tmp_path: Path, monkeypatch) -> None:
    data_dir = tmp_path / "data" / "processed"
    data_dir.mkdir(parents=True)
    data_path = data_dir / "processed_data.csv"
    data_path.write_text(
        "trip_duration,trip_distance,passenger_count\n600,2.5,1\n900,5.0,2\n300,1.0,1\n"
    )

    model_dir = tmp_path / "models"
    model_dir.mkdir()
    model_path = model_dir / "model.json"
    model_path.write_text(
        json.dumps(
            {"type": "mean_baseline", "target": "trip_duration", "target_mean": 600.0}
        )
    )

    output_path = tmp_path / "reports" / "evaluation.json"

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
