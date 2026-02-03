#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path


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


def _render_env(
    demo_keys: list[str], demo_values: dict[str, str], env_values: dict[str, str]
) -> str:
    lines: list[str] = []
    for key in demo_keys:
        value = env_values.get(key, demo_values.get(key, ""))
        lines.append(f"{key}={value}")
    return "\n".join(lines) + "\n"


def _prompt_value(key: str, default: str) -> str:
    prompt = f"{key} [{default}]: "
    entered = input(prompt)
    return entered if entered != "" else default


def main() -> int:
    parser = argparse.ArgumentParser(description="Render config/.env from config/.env.demo")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("-i", "--interactive", action="store_true", help="prompt for each value")
    mode.add_argument(
        "-n",
        "--non-interactive",
        action="store_true",
        help="use existing .env values when available",
    )
    parser.add_argument("--check", action="store_true", help="exit non-zero if render differs")
    parser.add_argument("--demo-file", default="config/.env.demo")
    parser.add_argument("--env-file", default="config/.env")
    args = parser.parse_args()

    demo_path = Path(args.demo_file)
    env_path = Path(args.env_file)

    if not demo_path.exists():
        print(f"Missing demo file: {demo_path}", file=sys.stderr)
        return 2

    try:
        demo_keys, demo_values = _parse_env(demo_path)
    except ValueError as exc:
        print(str(exc), file=sys.stderr)
        return 2

    env_values: dict[str, str] = {}
    if env_path.exists():
        try:
            _, env_values = _parse_env(env_path)
        except ValueError as exc:
            print(str(exc), file=sys.stderr)
            return 2

    if args.interactive:
        rendered_values: dict[str, str] = {}
        for key in demo_keys:
            default = env_values.get(key, demo_values.get(key, ""))
            rendered_values[key] = _prompt_value(key, default)
        rendered = "\n".join(f"{key}={rendered_values[key]}" for key in demo_keys) + "\n"
    else:
        rendered = _render_env(demo_keys, demo_values, env_values)

    current = ""
    if env_path.exists():
        current = env_path.read_text(encoding="utf-8")

    if args.check:
        if current != rendered:
            print("config/.env is out of sync with config/.env.demo", file=sys.stderr)
            return 1
        print("OK: config/.env matches rendered output")
        return 0

    env_path.write_text(rendered, encoding="utf-8")
    print(f"Wrote {env_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
