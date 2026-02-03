#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[2]


def _resolve_path(path: Path) -> Path:
    return path if path.is_absolute() else PROJECT_ROOT / path


def _parse_env(path: Path) -> tuple[list[str], dict[str, str]]:
    text = path.read_text(encoding="utf-8")
    keys: list[str] = []
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
        keys.append(key)
        values[key] = value
    return keys, values


def _diff_keys(demo_keys: list[str], env_keys: list[str]) -> tuple[list[str], list[str], bool]:
    demo_set = set(demo_keys)
    env_set = set(env_keys)
    missing = [key for key in demo_keys if key not in env_set]
    extra = [key for key in env_keys if key not in demo_set]
    order_matches = demo_keys == env_keys
    return missing, extra, order_matches


def main() -> int:
    parser = argparse.ArgumentParser(description="Check that config/.env matches config/.env.demo")
    parser.add_argument("--demo-file", default="config/.env.demo")
    parser.add_argument("--env-file", default="config/.env")
    args = parser.parse_args()

    demo_path = _resolve_path(Path(args.demo_file))
    env_path = _resolve_path(Path(args.env_file))

    if not demo_path.exists():
        print(f"Missing demo file: {demo_path}", file=sys.stderr)
        return 2
    if not env_path.exists():
        print(f"Missing env file: {env_path}", file=sys.stderr)
        return 2

    try:
        demo_keys, _ = _parse_env(demo_path)
        env_keys, _ = _parse_env(env_path)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    missing, extra, order_matches = _diff_keys(demo_keys, env_keys)
    if not missing and not extra and order_matches:
        print("OK: config/.env is synced with config/.env.demo")
        return 0

    print("config/.env is out of sync with config/.env.demo", file=sys.stderr)
    if missing:
        print(f"Missing keys: {', '.join(missing)}", file=sys.stderr)
    if extra:
        print(f"Extra keys: {', '.join(extra)}", file=sys.stderr)
    if not order_matches and not missing and not extra:
        print("Key order differs from config/.env.demo", file=sys.stderr)
    print("Run scripts/setup/env-render.py --interactive to sync.", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
