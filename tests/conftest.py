from __future__ import annotations

import importlib.util
import sys
from pathlib import Path

import pytest


SRC_PATH = Path(__file__).resolve().parents[1] / "src"
if str(SRC_PATH) not in sys.path:
    sys.path.insert(0, str(SRC_PATH))

ROOT_PATH = Path(__file__).resolve().parents[1]
if str(ROOT_PATH) not in sys.path:
    sys.path.insert(0, str(ROOT_PATH))


def pytest_sessionstart(session: pytest.Session) -> None:
    required = ["fastapi", "pandas", "dagster"]
    missing = [name for name in required if importlib.util.find_spec(name) is None]
    if missing:
        raise pytest.UsageError(
            "Missing required test dependencies: "
            + ", ".join(missing)
            + ". Run `uv sync` to install them."
        )
