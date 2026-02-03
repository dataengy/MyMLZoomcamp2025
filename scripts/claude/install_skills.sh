#!/usr/bin/env bash
# ==================================================================
# install_skills.sh — copy .ai/skills/ → .claude/skills/
#
# Assembles SKILL.md on-the-fly from skill.yml + prompt.md so that
# Claude Code discovers each skill automatically.
#
# Usage:
#   scripts/claude/install_skills.sh [OPTIONS]
#
# Options:
#   --local      target project .claude/skills/   (default)
#   --global     target ~/.claude/skills/
#   --only NAME  install only the named skill
#   --force      overwrite already-installed skills
#   --dry-run    show actions without writing files
#   --list       print available skills and exit
#   -h --help    show this message
# ==================================================================
set -euo pipefail

# ── source logging helpers ──────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
# shellcheck source=/dev/null
source "$PROJECT_ROOT/scripts/utils/log4bash.sh"

# ── paths ───────────────────────────────────────────────────────
SRC="$PROJECT_ROOT/.ai/skills"

# ── defaults ────────────────────────────────────────────────────
MODE=local # local | global
FORCE=0
DRY_RUN=0
ONLY=""
LIST_ONLY=0

# ── usage ───────────────────────────────────────────────────────
usage() {
  sed -n '/^# Usage:/,/^# ==/{/^# ==/!s/^# \{0,2\}//p}' "$0"
}

# ── arg-parse ───────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local)
      MODE=local
      shift
      ;;
    --global)
      MODE=global
      shift
      ;;
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
      log_error "unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# ── destination ─────────────────────────────────────────────────
if [[ "$MODE" == "global" ]]; then
  DEST="$HOME/.claude/skills"
else
  DEST="$PROJECT_ROOT/.claude/skills"
fi

# ── helpers ─────────────────────────────────────────────────────

# yaml_get FILE KEY – read a plain single-line value
yaml_get() {
  awk -v k="$2" '
    $0 ~ "^" k ": " {
      sub("^" k ": *", "")
      gsub(/^"|"$/, "")     # strip surrounding quotes
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

# ── list ────────────────────────────────────────────────────────
list_skills() {
  printf "%-24s %-8s %-20s %s\n" "NAME" "VER" "CATEGORY" "DESCRIPTION"
  printf "%-24s %-8s %-20s %s\n" "────" "───" "────────" "───────────"
  for d in "$SRC"/*/; do
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

# assemble_skill SRC_DIR DEST_DIR – write SKILL.md + copy artifacts
assemble_skill() {
  local src_dir="$1" dest_dir="$2"
  local name desc

  name=$(yaml_get "$src_dir/skill.yml" name)
  desc=$(yaml_desc "$src_dir/skill.yml")

  mkdir -p "$dest_dir"

  # SKILL.md = frontmatter (name + desc) + prompt body
  {
    echo '---'
    echo "name: $name"
    echo "description: $desc"
    echo '---'
    echo
    cat "$src_dir/prompt.md"
  } >"$dest_dir/SKILL.md"

  # templates/ – reusable scaffolding referenced by the prompt
  [[ -d "$src_dir/templates" ]] && cp -R "$src_dir/templates" "$dest_dir/templates"

  # skill.yml – kept as supplementary metadata
  cp "$src_dir/skill.yml" "$dest_dir/skill.yml"
}

# ── main ────────────────────────────────────────────────────────
if [[ ! -d "$SRC" ]]; then
  log_error "source dir not found: $SRC"
  exit 2
fi

if [[ $LIST_ONLY -eq 1 ]]; then
  list_skills
  exit 0
fi

# validate --only target
if [[ -n "$ONLY" && ! -d "$SRC/$ONLY" ]]; then
  log_error "skill '$ONLY' not found in $SRC"
  echo
  list_skills
  exit 2
fi

log_info "source : $SRC"
log_info "target : $DEST ($MODE)"
[[ $DRY_RUN -eq 1 ]] && log_info "(dry-run — no files will be written)"
echo

installed=0
skipped=0

for d in "$SRC"/*/; do
  [[ -f "$d/skill.yml" ]] || continue
  [[ -f "$d/prompt.md" ]] || {
    log_warn "$(basename "$d") — prompt.md missing, skipped"
    continue
  }

  name=$(yaml_get "$d/skill.yml" name)
  [[ -n "$ONLY" && "$name" != "$ONLY" ]] && continue

  dest_dir="$DEST/$name"

  # ── already-installed check ───────────────────────────────────
  if [[ -d "$dest_dir" && $FORCE -eq 0 ]]; then
    log_info "  skip     $name  (use --force to overwrite)"
    skipped=$((skipped + 1))
    continue
  fi

  # ── dry-run gate ──────────────────────────────────────────────
  if [[ $DRY_RUN -eq 1 ]]; then
    log_info "  install  $name  →  $dest_dir"
    installed=$((installed + 1))
    continue
  fi

  # ── write ─────────────────────────────────────────────────────
  [[ -d "$dest_dir" ]] && rm -rf "$dest_dir"
  assemble_skill "$d" "$dest_dir"
  log_info "  install  $name  →  $dest_dir"
  installed=$((installed + 1))
done

echo
log_info "Done — installed: $installed  skipped: $skipped"
