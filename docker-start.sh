#!/usr/bin/env sh
set -eu

# ============================================================================
# Docker Start Script - Function-based with CLI and Interactive Mode
# ============================================================================

ROOT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
COMPOSE_FILE="$ROOT_DIR/deploy/docker-compose.yml"

# Source utilities
# shellcheck disable=SC1091
. "$ROOT_DIR/scripts/utils/utils.sh"

# ============================================================================
# Configuration Variables
# ============================================================================

BUILD=1
NO_CACHE=0
DETACH=0
INTERACTIVE=0
MENU_MODE=0
COMMAND=
SERVICE=

# ============================================================================
# Helper Functions
# ============================================================================

usage() {
  cat <<'USAGE'
Usage: ./docker-start.sh [options] [service]

Options:
  -b, --build           Build before starting (default)
  --no-build            Skip build
  -n, --no-cache        Build with --no-cache
  -d, --detach          Run in background
  -i, --interactive     Attach to a service with exec
  -m, --menu            Interactive menu mode
  -c, --command CMD     Command to run (with --interactive)
  -h, --help            Show this help

Services:
  api                   FastAPI service
  dagster               Dagster orchestration
  streamlit             Streamlit UI
  jupyter               Jupyter Lab

Examples:
  ./docker-start.sh api
  ./docker-start.sh --no-build
  ./docker-start.sh --no-cache api
  ./docker-start.sh -d streamlit
  ./docker-start.sh -i api
  ./docker-start.sh -i -c "bash" api
  ./docker-start.sh --menu
USAGE
}

compose() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

# ============================================================================
# Dependency Checks
# ============================================================================

check_dependencies() {
  cd "$ROOT_DIR"

  # Check direnv
  if have direnv; then
    if [ -f .envrc ]; then
      direnv allow >/dev/null 2>&1 || true
      direnv reload >/dev/null 2>&1 || true
    fi
  else
    warn "direnv not installed; skipping .envrc loading."
  fi

  # Check docker
  if ! have docker; then
    fail "docker not found in PATH"
  fi

  # Check docker compose
  if ! docker compose version >/dev/null 2>&1; then
    fail "docker compose not available"
  fi

  # Check compose file
  if [ ! -f "$COMPOSE_FILE" ]; then
    fail "docker-compose.yml not found at $COMPOSE_FILE"
  fi
}

# ============================================================================
# CLI Argument Parsing
# ============================================================================

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -b | --build)
        BUILD=1
        ;;
      --no-build)
        BUILD=0
        ;;
      -n | --no-cache)
        NO_CACHE=1
        ;;
      -d | --detach)
        DETACH=1
        ;;
      -i | --interactive)
        INTERACTIVE=1
        ;;
      -m | --menu)
        MENU_MODE=1
        ;;
      -c | --command)
        shift
        COMMAND=${1:-}
        if [ -z "$COMMAND" ]; then
          fail "--command requires a value"
        fi
        ;;
      -h | --help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        fail "Unknown option: $1"
        ;;
      *)
        SERVICE=$1
        ;;
    esac
    shift
  done

  if [ -z "$SERVICE" ] && [ $# -gt 0 ]; then
    SERVICE=$1
  fi
}

# ============================================================================
# Interactive Menu Mode
# ============================================================================

show_menu() {
  cat <<'MENU'

=== Docker Services Menu ===
1) Start API (foreground)
2) Start API (background)
3) Start Dagster (foreground)
4) Start Dagster (background)
5) Start Streamlit (foreground)
6) Start Streamlit (background)
7) Start Jupyter (foreground)
8) Start Jupyter (background)
9) Start all services (background)
10) Interactive shell (select service)
11) Build all services
12) Build with --no-cache
13) Stop all services
14) View logs
0) Exit

MENU
  printf "Enter choice [0-14]: "
}

interactive_menu() {
  while true; do
    show_menu
    read -r choice

    case $choice in
      1)
        log "Starting API in foreground"
        SERVICE="api"
        DETACH=0
        start_services
        ;;
      2)
        log "Starting API in background"
        SERVICE="api"
        DETACH=1
        start_services
        ;;
      3)
        log "Starting Dagster in foreground"
        SERVICE="dagster"
        DETACH=0
        start_services
        ;;
      4)
        log "Starting Dagster in background"
        SERVICE="dagster"
        DETACH=1
        start_services
        ;;
      5)
        log "Starting Streamlit in foreground"
        SERVICE="streamlit"
        DETACH=0
        start_services
        ;;
      6)
        log "Starting Streamlit in background"
        SERVICE="streamlit"
        DETACH=1
        start_services
        ;;
      7)
        log "Starting Jupyter in foreground"
        SERVICE="jupyter"
        DETACH=0
        start_services
        ;;
      8)
        log "Starting Jupyter in background"
        SERVICE="jupyter"
        DETACH=1
        start_services
        ;;
      9)
        log "Starting all services in background"
        SERVICE=""
        DETACH=1
        start_services
        ;;
      10)
        select_service_for_shell
        ;;
      11)
        log "Building all services"
        BUILD=1
        NO_CACHE=0
        build_services
        ;;
      12)
        log "Building all services with --no-cache"
        BUILD=1
        NO_CACHE=1
        build_services
        ;;
      13)
        log "Stopping all services"
        compose down
        ;;
      14)
        select_service_for_logs
        ;;
      0)
        log "Exiting"
        exit 0
        ;;
      *)
        warn "Invalid choice: $choice"
        ;;
    esac

    if [ "$DETACH" -eq 0 ] && [ "$choice" != "0" ]; then
      # If running in foreground, wait for user to continue
      printf "\nPress Enter to continue..."
      read -r _
    fi
  done
}

select_service_for_shell() {
  cat <<'SERVICES'

Select service for interactive shell:
1) api
2) dagster
3) streamlit
4) jupyter
0) Back to main menu

SERVICES
  printf "Enter choice [0-4]: "
  read -r svc_choice

  case $svc_choice in
    1) SERVICE="api" ;;
    2) SERVICE="dagster" ;;
    3) SERVICE="streamlit" ;;
    4) SERVICE="jupyter" ;;
    0) return ;;
    *)
      warn "Invalid choice"
      return
      ;;
  esac

  log "Starting $SERVICE in background for shell access"
  compose up -d "$SERVICE"
  log "Opening shell in $SERVICE"
  compose exec "$SERVICE" sh
}

select_service_for_logs() {
  cat <<'SERVICES'

Select service to view logs:
1) api
2) dagster
3) streamlit
4) jupyter
5) all services
0) Back to main menu

SERVICES
  printf "Enter choice [0-5]: "
  read -r log_choice

  case $log_choice in
    1) compose logs -f api ;;
    2) compose logs -f dagster ;;
    3) compose logs -f streamlit ;;
    4) compose logs -f jupyter ;;
    5) compose logs -f ;;
    0) return ;;
    *)
      warn "Invalid choice"
      return
      ;;
  esac
}

# ============================================================================
# Service Operations
# ============================================================================

build_services() {
  if [ "$BUILD" -eq 0 ]; then
    log "Skipping build"
    return
  fi

  if [ -n "$SERVICE" ]; then
    log "Building service: $SERVICE"
    if [ "$NO_CACHE" -eq 1 ]; then
      compose build --no-cache "$SERVICE"
    else
      compose build "$SERVICE"
    fi
  else
    log "Building all services"
    if [ "$NO_CACHE" -eq 1 ]; then
      compose build --no-cache
    else
      compose build
    fi
  fi
}

start_services() {
  log "Starting ${SERVICE:-all services}"
  if [ "$DETACH" -eq 1 ]; then
    if [ -n "$SERVICE" ]; then
      compose up -d "$SERVICE"
    else
      compose up -d
    fi
  else
    if [ -n "$SERVICE" ]; then
      compose up "$SERVICE"
    else
      compose up
    fi
  fi
}

interactive_session() {
  if [ -z "$SERVICE" ]; then
    fail "--interactive requires a service name"
  fi

  log "Starting service (detached) for interactive session: $SERVICE"
  compose up -d "$SERVICE"

  if [ -n "$COMMAND" ]; then
    log "Executing command in $SERVICE: $COMMAND"
    compose exec "$SERVICE" sh -lc "$COMMAND"
  else
    log "Opening shell in $SERVICE"
    compose exec "$SERVICE" sh
  fi
}

# ============================================================================
# Main Entry Point
# ============================================================================

main() {
  check_dependencies
  parse_args "$@"

  # Menu mode takes precedence
  if [ "$MENU_MODE" -eq 1 ]; then
    interactive_menu
    exit 0
  fi

  # Build if needed
  build_services

  # Interactive session mode
  if [ "$INTERACTIVE" -eq 1 ]; then
    interactive_session
    exit 0
  fi

  # Normal start
  start_services
}

# Run main
main "$@"
