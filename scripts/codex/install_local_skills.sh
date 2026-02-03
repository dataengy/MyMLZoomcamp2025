#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SRC_SKILLS="$PROJECT_ROOT/.ai/.codex/skills"
DEST_CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
DEST_SKILLS="$DEST_CODEX_HOME/skills"

FORCE=0
DRY_RUN=0
ONLY=""
LIST_ONLY=0

usage() {
  cat <<'USAGE'
Usage: install_local_skills.sh [OPTIONS]

Options:
  --force       overwrite already-installed skills
  --dry-run     show actions without writing files
  --only NAME   install only the named skill
  --list        list available skills and exit
  -h, --help    show this message
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force)
      FORCE=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --only)
      ONLY="${2:?--only requires NAME}"
      shift 2
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ ! -d "$SRC_SKILLS" ]]; then
  echo "Source skills directory not found: $SRC_SKILLS" >&2
  exit 2
fi

# yaml_get FILE KEY – read a plain single-line value
yaml_get() {
  awk -v k="$2" '
    $0 ~ "^" k ": " {
      sub("^" k ": *", "")
      gsub(/^\"|\"$/, "")
      print; exit
    }
  ' "$1"
}

# yaml_desc FILE – read description (handles > folded scalar)
yaml_desc() {
  local first
  first=$(awk '/^description:/{sub(/^description: */, ""); print; exit}' "$1")
  if [[ "$first" == ">" || "$first" == "|" ]]; then
    awk '
      /^description: *[>|]/ { found=1; next }
      found && /^[[:space:]]/ { sub(/^[[:space:]]+/, ""); printf "%s ", $0; next }
      found { exit }
    ' "$1" | sed 's/ *$//'
  else
    echo "$first"
  fi
}

list_skills() {
  printf "%-24s %-8s %-20s %s\n" "NAME" "VER" "CATEGORY" "DESCRIPTION"
  printf "%-24s %-8s %-20s %s\n" "────" "───" "────────" "───────────"
  for d in "$SRC_SKILLS"/*/; do
    [[ -f "$d/skill.yml" ]] || continue
    local n v c desc
    n=$(yaml_get "$d/skill.yml" name)
    v=$(yaml_get "$d/skill.yml" version)
    c=$(yaml_get "$d/skill.yml" category)
    desc=$(yaml_desc "$d/skill.yml")
    [[ ${#desc} -gt 42 ]] && desc="${desc:0:39}..."
    printf "%-24s %-8s %-20s %s\n" "$n" "$v" "$c" "$desc"
  done
}

assemble_skill() {
  local src_dir="$1" dest_dir="$2"
  local name desc

  name=$(yaml_get "$src_dir/skill.yml" name)
  desc=$(yaml_desc "$src_dir/skill.yml")

  mkdir -p "$dest_dir"

  {
    echo '---'
    echo "name: $name"
    echo "description: $desc"
    echo '---'
    echo
    cat "$src_dir/prompt.md"
  } >"$dest_dir/SKILL.md"

  [[ -d "$src_dir/templates" ]] && cp -R "$src_dir/templates" "$dest_dir/templates"
  cp "$src_dir/skill.yml" "$dest_dir/skill.yml"
}

if [[ $LIST_ONLY -eq 1 ]]; then
  list_skills
  exit 0
fi

if [[ -n "$ONLY" && ! -d "$SRC_SKILLS/$ONLY" ]]; then
  echo "Skill '$ONLY' not found in $SRC_SKILLS" >&2
  echo
  list_skills
  exit 2
fi

mkdir -p "$DEST_SKILLS"

installed=0
skipped=0

for skill_dir in "$SRC_SKILLS"/*; do
  [[ -d "$skill_dir" ]] || continue
  [[ -f "$skill_dir/skill.yml" ]] || continue
  [[ -f "$skill_dir/prompt.md" ]] || {
    echo "Skip: $(basename "$skill_dir") missing prompt.md" >&2
    continue
  }

  name=$(yaml_get "$skill_dir/skill.yml" name)
  [[ -n "$ONLY" && "$name" != "$ONLY" ]] && continue

  dest="$DEST_SKILLS/$name"

  if [[ -d "$dest" && "$FORCE" != "1" ]]; then
    echo "Skip: $name already installed at $dest (use --force to overwrite)"
    skipped=$((skipped + 1))
    continue
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    echo "Install: $name -> $dest"
    installed=$((installed + 1))
    continue
  fi

  [[ -d "$dest" && "$FORCE" == "1" ]] && rm -rf "$dest"
  assemble_skill "$skill_dir" "$dest"
  echo "Installed: $name -> $dest"
  installed=$((installed + 1))
done

echo "Done. Installed: $installed, Skipped: $skipped"
