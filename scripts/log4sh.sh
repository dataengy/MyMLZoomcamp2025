#!/usr/bin/env sh

# Minimal log4sh-style helpers using LOG_LEVEL.
LOG_LEVEL=${LOG_LEVEL:-INFO}

_log_level_num() {
  case "$1" in
    DEBUG) echo 10 ;;
    INFO) echo 20 ;;
    WARN) echo 30 ;;
    ERROR) echo 40 ;;
    *) echo 20 ;;
  esac
}

_log_enabled() {
  [ "$(_log_level_num "$1")" -ge "$(_log_level_num "$LOG_LEVEL")" ]
}

_log_emit() {
  level="$1"
  shift
  ts=$(date "+%Y-%m-%d %H:%M:%S")
  printf '%s | %-5s | %s\n' "$ts" "$level" "$*"
}

log_debug() { _log_enabled DEBUG && _log_emit DEBUG "$*"; }
log_info() { _log_enabled INFO && _log_emit INFO "$*"; }
log_warn() { _log_enabled WARN && _log_emit WARN "$*" >&2; }
log_error() { _log_enabled ERROR && _log_emit ERROR "$*" >&2; }
