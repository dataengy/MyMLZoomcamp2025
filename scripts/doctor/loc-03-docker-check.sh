#!/usr/bin/env bash
#
# Doctor script: Docker environment check
# Validates Docker daemon, compose plugin, and project compose file.
#
# Usage:
#   ./loc-03-docker-check.sh [--verbose]
#

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
COMPOSE_FILE="$PROJECT_ROOT/deploy/docker-compose.yml"

# Colors
R='\033[31m' G='\033[32m' Y='\033[33m' B='\033[34m' C='\033[36m' N='\033[0m'

say() { printf "%b\n" "$*"; }
ok() { say "[${G}OK${N}] $*"; }
warn() { say "[${Y}WARN${N}] $*"; }
err() { say "[${R}ERROR${N}] $*"; }

VERBOSE=false
ISSUES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose | -v)
      VERBOSE=true
      shift
      ;;
    -h | --help)
      say "Usage: $0 [--verbose]"
      exit 0
      ;;
    *)
      err "Unknown argument: $1"
      exit 1
      ;;
  esac
done

say "${B}=== Docker Environment Check ===${N}"
say "Project: ${C}${PROJECT_ROOT}${N}"
say ""

# 1. Docker binary
say "Checking docker binary..."
if command -v docker >/dev/null 2>&1; then
  ver=$(docker --version 2>/dev/null || echo "unknown")
  ok "docker found — $ver"
else
  err "docker not found in PATH"
  ((ISSUES++))
fi

# 2. Docker daemon reachability
say "Checking docker daemon..."
if docker info >/dev/null 2>&1; then
  ok "Docker daemon is running"
else
  err "Cannot connect to Docker daemon. Is it running?"
  ((ISSUES++))
fi

# 3. docker compose plugin
say "Checking docker compose plugin..."
if docker compose version >/dev/null 2>&1; then
  cver=$(docker compose version 2>/dev/null || echo "unknown")
  ok "docker compose available — $cver"
else
  err "docker compose plugin not found"
  ((ISSUES++))
fi

# 4. Compose file exists and parses
say "Checking compose file..."
if [[ ! -f "$COMPOSE_FILE" ]]; then
  err "docker-compose.yml not found at $COMPOSE_FILE"
  ((ISSUES++))
else
  if docker compose -f "$COMPOSE_FILE" config >/dev/null 2>&1; then
    ok "Compose file parses successfully"
    if [[ "$VERBOSE" == "true" ]]; then
      say "  Services:"
      docker compose -f "$COMPOSE_FILE" config --services | while read -r svc; do
        say "    - $svc"
      done
    fi
  else
    err "Compose file has syntax errors"
    docker compose -f "$COMPOSE_FILE" config 2>&1 | head -5
    ((ISSUES++))
  fi
fi

# 5. No orphan containers from this project
say "Checking for orphan containers..."
if docker compose -f "$COMPOSE_FILE" ps --quiet 2>/dev/null | grep -q .; then
  warn "Running containers found — use 'docker compose -f deploy/docker-compose.yml down' to stop"
  if [[ "$VERBOSE" == "true" ]]; then
    docker compose -f "$COMPOSE_FILE" ps --format 'table {{.Name}}\t{{.Status}}'
  fi
else
  ok "No running project containers"
fi

# Summary
say ""
say "${B}=== Summary ===${N}"
if [[ $ISSUES -eq 0 ]]; then
  say "${G}All docker checks passed.${N}"
  exit 0
else
  say "${Y}Found $ISSUES issue(s).${N}"
  exit 1
fi
