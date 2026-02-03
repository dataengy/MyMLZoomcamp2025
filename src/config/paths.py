from __future__ import annotations

import os
from pathlib import Path


def _require_env(name: str) -> str:
    value = os.getenv(name)
    if value is None or value == "":
        raise RuntimeError(f"Missing required env var: {name}. Set it in config/.env.")
    return value


RUN_DIR = Path(_require_env("RUN_DIR"))
REPORTS_DIR = Path(_require_env("REPORTS_DIR"))
LOGS_DIR = Path(_require_env("LOG_DIR"))
DAGSTER_HOME = Path(_require_env("DAGSTER_HOME"))
