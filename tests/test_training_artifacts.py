from pathlib import Path

from training.train import main


def test_training_writes_placeholder_artifacts(tmp_path: Path, monkeypatch) -> None:
    monkeypatch.chdir(tmp_path)
    main()

    assert (tmp_path / "models" / "model.joblib").exists()
    assert (tmp_path / "reports" / "metrics.json").exists()
