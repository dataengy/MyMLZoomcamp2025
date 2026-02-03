#!/usr/bin/env bash
set -euo pipefail

# Minimal log4bash-style helpers using LOG_LEVEL.
LOG_LEVEL="${LOG_LEVEL:-INFO}"

log_level_num() {
  case "$1" in
    DEBUG) echo 10 ;;
    INFO) echo 20 ;;
    WARN) echo 30 ;;
    ERROR) echo 40 ;;
    *) echo 20 ;;
  esac
}

log_level_emoji() {
  case "$1" in
    DEBUG) echo "🐛" ;;
    INFO) echo "ℹ️" ;;
    WARN) echo "⚠️" ;;
    ERROR) echo "❌" ;;
    *) echo "•" ;;
  esac
}

log_place() {
  if [[ -n "${LOG_PLACE:-}" ]]; then
    echo "$LOG_PLACE"
    return
  fi
  local src=""
  local line=""
  local base=""
  local i
  local internal_base
  internal_base="$(basename -- "${BASH_SOURCE[0]:-}")"
  for i in "${!BASH_SOURCE[@]}"; do
    if [[ "$i" -eq 0 ]]; then
      continue
    fi
    src="${BASH_SOURCE[$i]:-}"
    base=$(basename -- "${src:-}")
    if [[ "$base" != "$internal_base" && "$base" != "log.sh" ]]; then
      line="${BASH_LINENO[$((i - 1))]:-}"
      break
    fi
  done
  if [[ -n "$src" && -n "$line" ]]; then
    printf '%s:%s\n' "$base" "$line"
    return
  fi
  if [[ -n "$src" ]]; then
    echo "$base"
    return
  fi
  echo "-"
}

log_enabled() {
  [[ "$(log_level_num "$1")" -ge "$(log_level_num "$LOG_LEVEL")" ]]
}

log_emit() {
  local level="$1"
  shift
  local ts
  local emoji
  local place
  ts=$(date "+%y/%m/%d %H:%M:%S")
  emoji=$(log_level_emoji "$level")
  place=$(log_place)
  printf '%s %s %s %s\n' "$ts" "$emoji" "$place" "$*"
}

log_debug() { log_enabled DEBUG && log_emit DEBUG "$*"; }
log_info() { log_enabled INFO && log_emit INFO "$*"; }
log_warn() { log_enabled WARN && log_emit WARN "$*" >&2; }
log_error() { log_enabled ERROR && log_emit ERROR "$*" >&2; }
