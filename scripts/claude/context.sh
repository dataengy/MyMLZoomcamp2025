#!/usr/bin/env bash
# ==================================================================
# context.sh — dump current session state for Claude / human
#
# Usage:
#   scripts/claude/context.sh [OPTIONS]
#
# Options:
#   --prompts N    last N entries from PROMPTS-LOG  (default: 5)
#   -h --help      show this message
#
# Outputs: branch, HEAD, last 3 commits, git status,
#          open TODOs, recent PROMPTS-LOG entries.
# ==================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# ── args ─────────────────────────────────────────────────────────
PROMPTS_N=5
while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompts)
      PROMPTS_N="${2:?--prompts requires N}"
      shift 2
      ;;
    -h | --help)
      sed -n '/^# Usage:/,/^# ==/{ /^# ==/!s/^# \{0,2\}//p }' "$0"
      exit 0
      ;;
    *)
      echo "unknown option: $1" >&2
      exit 1
      ;;
  esac
done

# ── helpers ──────────────────────────────────────────────────────
h() { printf '\n\033[1m── %s ──\033[0m\n' "$*"; }

# ── branch & HEAD ────────────────────────────────────────────────
h "Branch & HEAD"
branch=$(git -C "$ROOT" rev-parse --abbrev-ref HEAD)
git -C "$ROOT" log -1 --format="  branch : $branch%n  head   : %h  %ai%n  msg    : %s"

# ── last 3 commits ──────────────────────────────────────────────
h "Recent commits"
git -C "$ROOT" log -3 --format="  %h  %ai  %s"

# ── git status ───────────────────────────────────────────────────
h "Git status"
git -C "$ROOT" status --short | sed 's/^/  /'

# ── open TODOs ───────────────────────────────────────────────────
h "Open TODOs"
found_todo=0
for f in "$ROOT"/.ai/TODO.md "$ROOT"/.claude/TODO.md "$ROOT"/TODO.md; do
  [[ -f "$f" ]] || continue
  found_todo=1
  rel="${f#"$ROOT"/}"
  open=$(grep -c '^\- \[ \]' "$f" || true)
  done_n=$(grep -c '^\- \[x\]' "$f" || true)
  printf "  %-32s open: %d  done: %d\n" "$rel" "$open" "$done_n"
  grep '^\- \[ \]' "$f" | sed 's/^\- \[ \]/    ·/' || true
done
[[ $found_todo -eq 0 ]] && echo "  (no TODO files found)"

# ── PROMPTS-LOG (last N) ─────────────────────────────────────────
h "PROMPTS-LOG (last $PROMPTS_N)"
log="$ROOT/.claude/.PROMPTS-LOG.md"
if [[ -f "$log" ]]; then
  awk -F'|' '
    /^\| *---/ { found=1; next }
    found && /^\|/ {
      n=$2; ts=$3; task=$5
      gsub(/^ +| +$/, "", n)
      gsub(/^ +| +$/, "", ts)
      gsub(/^ +| +$/, "", task)
      split(ts, a, " "); time=a[2]
      if (length(task) > 64) task = substr(task, 1, 61) "..."
      printf "  #%s  %s  %s\n", n, time, task
    }
  ' "$log" | tail -n "$PROMPTS_N"
else
  echo "  (no PROMPTS-LOG)"
fi
echo
