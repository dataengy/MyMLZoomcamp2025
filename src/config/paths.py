from __future__ import annotations

import os
from pathlib import Path

RUN_DIR = Path(os.getenv("RUN_DIR", ".run"))
REPORTS_DIR = Path(os.getenv("REPORTS_DIR", str(RUN_DIR / "reports")))
LOGS_DIR = Path(os.getenv("LOG_DIR", os.getenv("LOGS_DIR", str(RUN_DIR / "logs"))))
DAGSTER_HOME = Path(os.getenv("DAGSTER_HOME", str(RUN_DIR / "dagster")))
