from __future__ import annotations

import json
from pathlib import Path

import pandas as pd

import dags.definitions as defs


def _set_env_defaults(monkeypatch, raw_dir: Path, processed_dir: Path, model_path: Path) -> None:
    monkeypatch.setenv("RAW_DATA_DIR", str(raw_dir))
    monkeypatch.setenv("PROCESSED_DATA_DIR", str(processed_dir))
    monkeypatch.setenv("MODEL_PATH", str(model_path))
    monkeypatch.setenv("DATA_TYPE", "fhv")
    monkeypatch.setenv("DATA_YEAR", "2024")
    monkeypatch.setenv("DATA_MONTHS", "1,2")
    monkeypatch.setenv("ALLOW_DOWNLOAD", "false")
    monkeypatch.setenv("DATA_SAMPLE", "true")
    monkeypatch.setenv("SAMPLE_SIZE", "")
    monkeypatch.setenv("OUTPUT_FORMAT", "csv")


def test_env_bool_and_parse_months(monkeypatch) -> None:
    monkeypatch.setenv("TEST_BOOL", "YES")
    assert defs._env_bool("TEST_BOOL") is True
    monkeypatch.setenv("TEST_BOOL", "0")
    assert defs._env_bool("TEST_BOOL") is False
    assert defs._parse_months("1, 2,  ,3") == [1, 2, 3]


def test_write_synthetic_raw(tmp_path: Path) -> None:
    output = defs._write_synthetic_raw(tmp_path)
    assert output.exists()
    second = defs._write_synthetic_raw(tmp_path)
    assert second == output


def test_raw_data_returns_existing(monkeypatch, tmp_path: Path) -> None:
    raw_dir = tmp_path / "raw"
    raw_dir.mkdir()
    file_path = raw_dir / "existing.csv"
    pd.DataFrame({"a": [1]}).to_csv(file_path, index=False)

    _set_env_defaults(monkeypatch, raw_dir, tmp_path / "processed", tmp_path / "model.pkl")

    result = defs.raw_data()
    assert result["status"] == "ready"
    assert str(file_path) in result["files"]


def test_raw_data_synthetic(monkeypatch, tmp_path: Path) -> None:
    raw_dir = tmp_path / "raw"
    _set_env_defaults(monkeypatch, raw_dir, tmp_path / "processed", tmp_path / "model.pkl")

    result = defs.raw_data()
    assert result["status"] == "synthetic"
    assert Path(result["files"][0]).exists()


def test_prepared_data_calls_process(monkeypatch, tmp_path: Path) -> None:
    raw_dir = tmp_path / "raw"
    processed_dir = tmp_path / "processed"
    model_path = tmp_path / "model.pkl"
    _set_env_defaults(monkeypatch, raw_dir, processed_dir, model_path)

    def fake_process_data(input_dir, output_dir, sample_size, output_format):
        return {"processed_path": str(output_dir / "out.csv")}

    monkeypatch.setattr(defs, "process_data", fake_process_data)

    result = defs.prepared_data({"status": "ready", "files": []})
    assert result["status"] == "prepared"
    assert result["processed_path"].endswith("out.csv")


def test_trained_model_and_evaluation_report(monkeypatch, tmp_path: Path) -> None:
    raw_dir = tmp_path / "raw"
    processed_dir = tmp_path / "processed"
    model_path = tmp_path / "model.pkl"
    _set_env_defaults(monkeypatch, raw_dir, processed_dir, model_path)

    monkeypatch.setattr(defs, "REPORTS_DIR", tmp_path / "reports")

    def fake_train_model(data_path, model_out, metrics_out):
        model_out.parent.mkdir(parents=True, exist_ok=True)
        model_out.write_text("model")
        metrics_out.parent.mkdir(parents=True, exist_ok=True)
        metrics_out.write_text("{}")

    def fake_evaluate_model(data_path, model_path):
        _ = data_path
        _ = model_path
        return {"rmse": 1.23}

    monkeypatch.setattr(defs, "train_model", fake_train_model)
    monkeypatch.setattr(defs, "evaluate_model", fake_evaluate_model)

    prepared = {"processed_path": str(processed_dir / "data.csv")}
    trained = defs.trained_model(prepared)
    assert Path(trained.model_path).exists()
    assert Path(trained.metrics_path).exists()

    metrics = defs.evaluation_report(prepared, trained)
    assert metrics["status"] == "evaluated"
    evaluation_path = Path(trained.evaluation_path)
    assert evaluation_path.exists()
    assert json.loads(evaluation_path.read_text()) == {"rmse": 1.23}
