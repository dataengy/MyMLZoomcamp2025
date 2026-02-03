from __future__ import annotations

import os
import sys
from collections.abc import Callable
from pathlib import Path
from typing import Any

import yaml
from loguru import logger

log = logger

_CONFIGURED = False
_DEFAULT_LONG_FORMAT = (
    "{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} - {message}"
)
_DEFAULT_SHORT_FORMAT = "{time:YY/MM/DD HH:mm:ss} {level.icon} {name}:{function}:{line} {message}"


def _parse_bool(value: Any, default: bool) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return bool(value)
    if isinstance(value, str):
        lowered = value.strip().lower()
        if lowered in {"1", "true", "yes", "y", "on"}:
            return True
        if lowered in {"0", "false", "no", "n", "off"}:
            return False
    return default


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

    raw_level = os.environ.get("LOG_LEVEL", log_cfg.get("level", "DEBUG"))
    level = raw_level.upper() if isinstance(raw_level, str) else raw_level
    format_style = os.environ.get("LOG_FORMAT", log_cfg.get("format_style", "long"))
    format_style = format_style.lower() if isinstance(format_style, str) else "long"
    fmt_long = log_cfg.get("format", _DEFAULT_LONG_FORMAT)
    fmt_short = log_cfg.get("format_short", _DEFAULT_SHORT_FORMAT)
    fmt: str | Callable[[dict[str, Any]], str] = fmt_short if format_style == "short" else fmt_long
    colorize = bool(log_cfg.get("colorize", True))
    backtrace = bool(log_cfg.get("backtrace", True))
    diagnose = bool(log_cfg.get("diagnose", False))
    running_tests = os.getenv("PYTEST_CURRENT_TEST") is not None
    default_enqueue = False if running_tests else True
    enqueue = _parse_bool(
        os.environ.get("LOG_ENQUEUE", log_cfg.get("enqueue", default_enqueue)),
        default_enqueue,
    )

    log.remove()
    log.add(
        sys.stderr,
        level=level,
        format=fmt,
        colorize=colorize,
        backtrace=backtrace,
        diagnose=diagnose,
        enqueue=enqueue,
    )

    file_cfg = log_cfg.get("file") if isinstance(log_cfg, dict) else None
    if isinstance(file_cfg, dict) and file_cfg.get("path"):
        file_path = Path(file_cfg["path"])
        file_path.parent.mkdir(parents=True, exist_ok=True)
        file_level = file_cfg.get("level", level)
        if isinstance(file_level, str):
            file_level = file_level.upper()
        log.add(
            file_path,
            level=file_level,
            format=fmt,
            rotation=file_cfg.get("rotation"),
            retention=file_cfg.get("retention"),
            enqueue=enqueue,
        )

    _CONFIGURED = True
