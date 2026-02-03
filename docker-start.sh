#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT_DIR"

. "$ROOT_DIR/scripts/utils.sh"

if have direnv; then
  if [ -f .envrc ]; then
    direnv allow >/dev/null 2>&1 || true
    direnv reload >/dev/null 2>&1 || true
  fi
else
  warn "direnv not installed; skipping .envrc loading."
fi

if ! have docker; then
  fail "docker not found in PATH"
fi

if ! docker compose version >/dev/null 2>&1; then
  fail "docker compose not available"
fi

SERVICE=${1:-}

if [ -n "$SERVICE" ]; then
  log "Building service: $SERVICE"
  docker compose build --no-cache "$SERVICE"
  log "Starting service: $SERVICE"
  docker compose up "$SERVICE"
else
  log "Building all services"
  docker compose build --no-cache
  log "Starting all services"
  docker compose up
fi
