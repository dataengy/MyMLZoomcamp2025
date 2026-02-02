from __future__ import annotations

from pathlib import Path

import pytest

pytest.importorskip("pandas")

from scripts.process_data import main


def test_process_data_writes_outputs_csv(tmp_path: Path) -> None:
    input_dir = tmp_path / "raw"
    output_dir = tmp_path / "processed"
    input_dir.mkdir()

    sample_csv = input_dir / "yellow_tripdata_2024-01.csv"
    sample_csv.write_text(
        "tpep_pickup_datetime,tpep_dropoff_datetime,passenger_count,trip_distance,fare_amount,PULocationID,DOLocationID\n"
        "2024-01-01 00:00:00,2024-01-01 00:10:00,1,2.5,12.5,132,138\n"
        "2024-01-01 01:00:00,2024-01-01 01:20:00,2,5.0,20.0,140,161\n"
        "2024-01-01 02:00:00,2024-01-01 02:05:00,1,1.0,6.0,100,101\n"
    )

    exit_code = main(
        [
            "--input-dir",
            str(input_dir),
            "--output-dir",
            str(output_dir),
            "--input-format",
            "csv",
            "--output-format",
            "csv",
        ]
    )

    assert exit_code == 0
    assert (output_dir / "processed_data.csv").exists()
    assert (output_dir / "features.txt").exists()
    assert (output_dir / "data_summary.txt").exists()
