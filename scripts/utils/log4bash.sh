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

log_enabled() {
  [[ "$(log_level_num "$1")" -ge "$(log_level_num "$LOG_LEVEL")" ]]
}

log_emit() {
  local level="$1"
  shift
  local ts
  ts=$(date "+%Y-%m-%d %H:%M:%S")
  printf '%s | %-5s | %s\n' "$ts" "$level" "$*"
}

log_debug() { log_enabled DEBUG && log_emit DEBUG "$*"; }
log_info() { log_enabled INFO && log_emit INFO "$*"; }
log_warn() { log_enabled WARN && log_emit WARN "$*" >&2; }
log_error() { log_enabled ERROR && log_emit ERROR "$*" >&2; }
