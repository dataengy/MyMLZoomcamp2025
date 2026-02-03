from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest


@pytest.mark.integration
def test_simple_data_test_creates_files(tmp_path: Path) -> None:
    repo_root = Path(__file__).resolve().parents[2]
    script_path = repo_root / "tests" / "bash" / "simple_data_test.py"

    result = subprocess.run(
        [sys.executable, str(script_path)],
        check=True,
        capture_output=True,
        text=True,
        cwd=tmp_path,
    )

    raw_csv = tmp_path / "data" / "raw" / "synthetic_taxi_data.csv"
    processed_csv = tmp_path / "data" / "processed" / "processed_taxi_data.csv"
    sample_json = tmp_path / "data" / "processed" / "processed_taxi_data.json"

    assert "Data Pipeline Test Complete" in result.stdout
    assert raw_csv.exists()
    assert processed_csv.exists()
    assert sample_json.exists()
