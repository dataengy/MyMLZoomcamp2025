#!/usr/bin/env sh

say() {
  printf '%s\n' "$*"
}

log() {
  say "[INFO] $*"
}

warn() {
  say "[WARN] $*" >&2
}

fail() {
  say "[ERROR] $*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}
