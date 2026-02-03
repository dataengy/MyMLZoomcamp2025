from __future__ import annotations

import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]


def _run(cmd: list[str]) -> None:
    result = subprocess.run(
        cmd,
        cwd=PROJECT_ROOT,
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        raise AssertionError(
            f"Command failed: {' '.join(cmd)}\nstdout:\n{result.stdout}\nstderr:\n{result.stderr}"
        )


def test_env_sync_scripts() -> None:
    _run([sys.executable, "scripts/setup/env-check.py"])
    _run([sys.executable, "scripts/setup/env-render.py", "--check"])
    _run(["bash", "scripts/setup/env-render.sh", "--check"])
