import os
import re
from pathlib import Path

from src.config import logging as log_config

_LONG_FORMAT = "{time:YYYY-MM-DD HH:mm:ss} | {level} | {message}"
_SHORT_FORMAT = "{time:YY/MM/DD HH:mm:ss} {level.icon} {name}:{function}:{line} {message}"


def _write_config(path: Path, format_style: str) -> Path:
    config = path / "config.yml"
    config.write_text(
        f"""
logging:
  level: INFO
  format: '{_LONG_FORMAT}'
  format_short: '{_SHORT_FORMAT}'
  format_style: {format_style}
  colorize: false
  backtrace: false
  diagnose: false
"""
    )
    return config


def _reset_logging() -> None:
    log_config._CONFIGURED = False
    log_config.log.remove()


def test_short_format_from_config(tmp_path, capsys):
    config = _write_config(tmp_path, "short")
    os.environ["LOG_ENQUEUE"] = "0"
    _reset_logging()
    log_config.configure_logging(config)

    log_config.log.info("hello short")
    captured = capsys.readouterr()

    assert "hello short" in captured.err
    assert re.search(r"\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}", captured.err)
    assert "ℹ" in captured.err


def test_log_format_env_overrides_config(tmp_path, capsys, monkeypatch):
    config = _write_config(tmp_path, "long")
    monkeypatch.setenv("LOG_FORMAT", "short")
    monkeypatch.setenv("LOG_ENQUEUE", "0")
    _reset_logging()
    log_config.configure_logging(config)

    log_config.log.info("hello env")
    captured = capsys.readouterr()

    assert "hello env" in captured.err
    assert re.search(r"\d{2}/\d{2}/\d{2} \d{2}:\d{2}:\d{2}", captured.err)
    assert "ℹ" in captured.err
