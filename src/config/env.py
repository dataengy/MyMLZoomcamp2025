from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_ENV_FILE = PROJECT_ROOT / "config/.env"
DEFAULT_DEMO_FILE = PROJECT_ROOT / "config/.env.demo"
ENV_CHECK_SCRIPT = PROJECT_ROOT / "scripts/setup/env-check.py"


def _resolve_path(path: Path) -> Path:
    return path if path.is_absolute() else PROJECT_ROOT / path


def _parse_env(path: Path) -> dict[str, str]:
    text = path.read_text(encoding="utf-8")
    values: dict[str, str] = {}
    for idx, raw_line in enumerate(text.splitlines(), start=1):
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in raw_line:
            raise ValueError(f"{path}: invalid line {idx}: missing '='")
        key, value = raw_line.split("=", 1)
        key = key.strip()
        if not key:
            raise ValueError(f"{path}: invalid line {idx}: empty key")
        if key in values:
            raise ValueError(f"{path}: duplicate key '{key}' on line {idx}")
        values[key] = value
    return values


def load_env(
    env_file: Path | None = None,
    demo_file: Path | None = None,
    *,
    check: bool = True,
    override: bool = False,
) -> None:
    env_path = _resolve_path(env_file or DEFAULT_ENV_FILE)
    demo_path = _resolve_path(demo_file or DEFAULT_DEMO_FILE)

    if check:
        result = subprocess.run(
            [
                sys.executable,
                str(ENV_CHECK_SCRIPT),
                "--demo-file",
                str(demo_path),
                "--env-file",
                str(env_path),
            ],
            cwd=PROJECT_ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            detail = result.stderr.strip() or result.stdout.strip()
            raise RuntimeError(f"env-check failed: {detail}")

    if not env_path.exists():
        raise RuntimeError(f"Missing env file: {env_path}")

    values = _parse_env(env_path)
    for key, value in values.items():
        if override or key not in os.environ:
            os.environ[key] = value


def require_env(name: str) -> str:
    value = os.getenv(name)
    if value is None:
        raise RuntimeError(f"Missing required env var: {name}. Set it in config/.env.")
    return value
