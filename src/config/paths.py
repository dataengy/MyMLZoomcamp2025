from __future__ import annotations

from pathlib import Path

from config.env import load_env, require_env

load_env()

RUN_DIR = Path(require_env("RUN_DIR"))
REPORTS_DIR = Path(require_env("REPORTS_DIR"))
LOGS_DIR = Path(require_env("LOG_DIR"))
DAGSTER_HOME = Path(require_env("DAGSTER_HOME"))
