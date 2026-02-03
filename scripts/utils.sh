#!/usr/bin/env sh

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

if [ -f "$SCRIPT_DIR/log4sh.sh" ]; then
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/log4sh.sh"
fi

say() {
  printf '%s\n' "$*"
}

log() {
  if command -v log_info >/dev/null 2>&1; then
    log_info "$*"
  else
    say "[INFO] $*"
  fi
}

warn() {
  if command -v log_warn >/dev/null 2>&1; then
    log_warn "$*"
  else
    say "[WARN] $*" >&2
  fi
}

fail() {
  if command -v log_error >/dev/null 2>&1; then
    log_error "$*"
  else
    say "[ERROR] $*" >&2
  fi
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}
