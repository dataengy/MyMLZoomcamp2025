#!/usr/bin/env python3
import argparse
import os
import sys
import zipfile

EXCLUDE_DIRS = {"__pycache__", ".git", ".DS_Store"}
EXCLUDE_FILES = {".DS_Store"}


def parse_frontmatter(skill_md_path: str) -> dict:
    with open(skill_md_path, encoding="utf-8") as f:
        lines = f.read().splitlines()

    if not lines or lines[0].strip() != "---":
        raise ValueError("SKILL.md missing YAML frontmatter start '---'.")

    frontmatter = {}
    for line in lines[1:]:
        if line.strip() == "---":
            break
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = value.strip()

    return frontmatter


def iter_skill_dirs(root: str):
    if os.path.isfile(os.path.join(root, "SKILL.md")):
        yield root
        return
    for name in sorted(os.listdir(root)):
        path = os.path.join(root, name)
        if not os.path.isdir(path):
            continue
        if os.path.isfile(os.path.join(path, "SKILL.md")):
            yield path


def package_skill(skill_dir: str, out_dir: str) -> str:
    skill_md = os.path.join(skill_dir, "SKILL.md")
    if not os.path.isfile(skill_md):
        raise FileNotFoundError(f"SKILL.md not found in {skill_dir}")

    frontmatter = parse_frontmatter(skill_md)
    name = frontmatter.get("name")
    desc = frontmatter.get("description")
    if not name or not desc:
        raise ValueError(f"Missing name/description in {skill_md}")

    skill_folder_name = os.path.basename(os.path.normpath(skill_dir))
    if name != skill_folder_name:
        raise ValueError(f"Skill name '{name}' does not match folder '{skill_folder_name}'")

    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, f"{name}.skill")

    with zipfile.ZipFile(out_path, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for root, dirs, files in os.walk(skill_dir):
            dirs[:] = [d for d in dirs if d not in EXCLUDE_DIRS]
            for filename in files:
                if filename in EXCLUDE_FILES:
                    continue
                full_path = os.path.join(root, filename)
                rel_path = os.path.relpath(full_path, skill_dir)
                zf.write(full_path, arcname=os.path.join(name, rel_path))

    return out_path


def main() -> int:
    parser = argparse.ArgumentParser(description="Package Codex skills into .skill files")
    parser.add_argument("path", help="Skill directory or a folder containing skills")
    parser.add_argument("--out", default=".ai/.codex/dist", help="Output directory")
    args = parser.parse_args()

    if not os.path.isdir(args.path):
        print(f"Path does not exist: {args.path}", file=sys.stderr)
        return 2

    packaged = []
    for skill_dir in iter_skill_dirs(args.path):
        try:
            out = package_skill(skill_dir, args.out)
            packaged.append(out)
        except Exception as exc:
            print(f"Failed to package {skill_dir}: {exc}", file=sys.stderr)
            return 1

    if not packaged:
        print("No skills found to package.", file=sys.stderr)
        return 1

    for path in packaged:
        print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
