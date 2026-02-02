from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import pytest

pytest.importorskip("pandas")


def test_load_data_script_reads_and_writes_csv(tmp_path: Path) -> None:
    source = tmp_path / "input.csv"
    output = tmp_path / "output.csv"
    source.write_text("a,b\n1,2\n3,4\n")

    result = subprocess.run(
        [
            sys.executable,
            "scripts/load_data.py",
            "--source",
            str(source),
            "--output",
            str(output),
        ],
        check=True,
        capture_output=True,
        text=True,
    )

    assert output.exists()
    assert "Loaded 2 rows" in result.stdout
