from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import Any

import yaml
from loguru import logger

log = logger

_CONFIGURED = False


def _load_config(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    data = yaml.safe_load(path.read_text())
    if not isinstance(data, dict):
        return {}
    return data


def configure_logging(config_path: Path | None = None) -> None:
    global _CONFIGURED
    if _CONFIGURED:
        return

    config_file = config_path or Path(os.environ.get("CONFIG_PATH", "config/config.yml"))
    data = _load_config(config_file)
    log_cfg = data.get("logging", {}) if isinstance(data, dict) else {}

    level = os.environ.get("LOG_LEVEL", log_cfg.get("level", "DEBUG"))
    fmt = log_cfg.get(
        "format",
        "{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}",
    )
    colorize = bool(log_cfg.get("colorize", True))
    backtrace = bool(log_cfg.get("backtrace", True))
    diagnose = bool(log_cfg.get("diagnose", False))

    log.remove()
    log.add(
        sys.stderr,
        level=level,
        format=fmt,
        colorize=colorize,
        backtrace=backtrace,
        diagnose=diagnose,
        enqueue=True,
    )

    file_cfg = log_cfg.get("file") if isinstance(log_cfg, dict) else None
    if isinstance(file_cfg, dict) and file_cfg.get("path"):
        file_path = Path(file_cfg["path"])
        file_path.parent.mkdir(parents=True, exist_ok=True)
        log.add(
            file_path,
            level=file_cfg.get("level", level),
            format=fmt,
            rotation=file_cfg.get("rotation"),
            retention=file_cfg.get("retention"),
            enqueue=True,
        )

    _CONFIGURED = True
