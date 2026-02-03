from __future__ import annotations

import random
import subprocess
import sys
from pathlib import Path

import pytest


@pytest.mark.integration
def test_simple_ml_test_writes_model_info(tmp_path: Path) -> None:
    repo_root = Path(__file__).resolve().parents[2]
    script_path = repo_root / "tests" / "bash" / "simple_ml_test.py"

    processed_dir = tmp_path / "data" / "processed"
    processed_dir.mkdir(parents=True, exist_ok=True)
    data_path = processed_dir / "processed_taxi_data.csv"

    headers = [
        "trip_distance",
        "passenger_count",
        "pickup_hour",
        "pickup_weekday",
        "pickup_is_weekend",
        "is_rush_hour",
        "speed_mph",
        "trip_duration",
    ]

    rows = []
    random.seed(42)
    for _ in range(30):
        trip_distance = random.uniform(0.5, 10.0)
        passenger_count = random.randint(1, 4)
        pickup_hour = random.randint(0, 23)
        pickup_weekday = random.randint(0, 6)
        pickup_is_weekend = int(pickup_weekday >= 5)
        is_rush_hour = int(pickup_hour in {7, 8, 9, 17, 18, 19})
        speed_mph = random.uniform(5.0, 35.0)
        trip_duration = trip_distance / speed_mph * 3600
        rows.append(
            [
                trip_distance,
                passenger_count,
                pickup_hour,
                pickup_weekday,
                pickup_is_weekend,
                is_rush_hour,
                speed_mph,
                trip_duration,
            ]
        )

    with data_path.open("w") as f:
        f.write(",".join(headers) + "\n")
        for row in rows:
            f.write(",".join(f"{value:.6f}" for value in row) + "\n")

    result = subprocess.run(
        [sys.executable, str(script_path)],
        check=True,
        capture_output=True,
        text=True,
        cwd=tmp_path,
    )

    model_info = tmp_path / "models" / "simple_model_info.json"

    assert "ML Training Complete" in result.stdout
    assert model_info.exists()
