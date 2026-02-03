from __future__ import annotations

import importlib.util
import os
import sys
from pathlib import Path

import pytest

SRC_PATH = Path(__file__).resolve().parents[1] / "src"
if str(SRC_PATH) not in sys.path:
    sys.path.insert(0, str(SRC_PATH))

ROOT_PATH = Path(__file__).resolve().parents[1]
if str(ROOT_PATH) not in sys.path:
    sys.path.insert(0, str(ROOT_PATH))

TEST_ENV_DEFAULTS = {
    "RAW_DATA_DIR": "data/raw_test",
    "PROCESSED_DATA_DIR": "data/processed_test",
    "DATA_TYPE": "yellow_tripdata",
    "DATA_YEAR": "2024",
    "DATA_MONTHS": "1,2,3",
    "ALLOW_DOWNLOAD": "0",
    "DATA_SAMPLE": "1",
    "SAMPLE_SIZE": "500",
    "OUTPUT_FORMAT": "csv",
    "MODEL_PATH": "models/model.joblib",
}

for key, value in TEST_ENV_DEFAULTS.items():
    os.environ.setdefault(key, value)


def require_optional(*names: str) -> None:
    missing = [name for name in names if importlib.util.find_spec(name) is None]
    if missing:
        pytest.skip(
            "Missing optional dependency: " + ", ".join(missing),
            allow_module_level=True,
        )


pytest.require_optional = require_optional


def pytest_sessionstart(session: pytest.Session) -> None:
    required = ["fastapi", "pandas", "dagster"]
    missing = [name for name in required if importlib.util.find_spec(name) is None]
    if missing and os.environ.get("REQUIRE_TEST_DEPS") == "1":
        raise pytest.UsageError(
            "Missing required test dependencies: "
            + ", ".join(missing)
            + ". Run `uv sync` to install them."
        )
