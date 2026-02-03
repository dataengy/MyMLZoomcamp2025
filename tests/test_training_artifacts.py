from pathlib import Path

import pytest

pytest.importorskip("pandas")

from training.train import main


def test_training_writes_baseline_artifacts(tmp_path: Path, monkeypatch) -> None:
    data_dir = tmp_path / "data" / "processed"
    data_dir.mkdir(parents=True)
    data_path = data_dir / "processed_data.csv"
    data_path.write_text(
        "trip_duration,trip_distance,passenger_count\n600,2.5,1\n900,5.0,2\n300,1.0,1\n"
    )

    monkeypatch.chdir(tmp_path)
    exit_code = main(
        [
            "--data",
            str(data_path),
            "--model-out",
            "models/model.json",
            "--metrics-out",
            ".run/reports/metrics.json",
        ]
    )

    assert exit_code == 0
    assert (tmp_path / "models" / "model.json").exists()
    assert (tmp_path / ".run" / "reports" / "metrics.json").exists()
