#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SRC_SKILLS="$PROJECT_ROOT/.ai/.codex/skills"
DEST_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DEST_SKILLS="$DEST_CODEX_HOME/skills"

FORCE="0"
if [[ "${1:-}" == "--force" ]]; then
  FORCE="1"
fi

if [[ ! -d "$SRC_SKILLS" ]]; then
  echo "Source skills directory not found: $SRC_SKILLS" >&2
  exit 2
fi

mkdir -p "$DEST_SKILLS"

installed=0
skipped=0

for skill_dir in "$SRC_SKILLS"/*; do
  [[ -d "$skill_dir" ]] || continue
  name="$(basename "$skill_dir")"
  dest="$DEST_SKILLS/$name"

  if [[ -d "$dest" && "$FORCE" != "1" ]]; then
    echo "Skip: $name already installed at $dest (use --force to overwrite)"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ -d "$dest" && "$FORCE" == "1" ]]; then
    rm -rf "$dest"
  fi

  cp -R "$skill_dir" "$dest"
  echo "Installed: $name -> $dest"
  installed=$((installed + 1))
done

echo "Done. Installed: $installed, Skipped: $skipped"
