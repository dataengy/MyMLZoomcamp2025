#!/usr/bin/env python3
from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path


def _build_env() -> dict[str, str]:
    env = os.environ.copy()
    env.setdefault("LOG_ENQUEUE", "0")
    env.setdefault("SAMPLE_SIZE", "500")
    env.setdefault("ALLOW_DOWNLOAD", "0")
    env.setdefault("DATA_SAMPLE", "1")
    env.setdefault("OUTPUT_FORMAT", "csv")
    env.pop("LOG_FORMAT", None)
    env.pop("LOG_LEVEL", None)
    return env


def main(argv: list[str] | None = None) -> int:
    args = list(argv) if argv is not None else sys.argv[1:]
    cmd = args or ["make", "test"]
    repo_root = Path(__file__).resolve().parents[2]
    return subprocess.call(cmd, env=_build_env(), cwd=repo_root)


if __name__ == "__main__":
    raise SystemExit(main())
