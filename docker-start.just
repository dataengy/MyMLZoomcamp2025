# docker-start.just - Detailed Docker workflow helpers
# Purpose:
# - Convenience wrappers around ./docker-start.sh and docker compose
# - Provides explicit recipes for common dev flows
# Usage:
#   just -f docker-start.just <recipe> [args]
# Examples:
#   just -f docker-start.just start service=api
#   just -f docker-start.just start-bg service=streamlit
#   just -f docker-start.just interactive service=api
#   just -f docker-start.just interactive service=api command='bash'
#   just -f docker-start.just logs service=dagster
#   just -f docker-start.just build-nocache service=jupyter

# Use bash with strict error handling
set shell := ["bash", "-euo", "pipefail", "-c"]

# Paths
COMPOSE_FILE := "deploy/docker-compose.yml"
DOCKER_START := "./docker-start.sh"

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

# Show docker-start.sh help
help:
    {{DOCKER_START}} --help

# Launch interactive menu
menu:
    {{DOCKER_START}} --menu

# -----------------------------------------------------------------------------
# Start services via docker-start.sh
# -----------------------------------------------------------------------------

# Start a service (or all if service is empty)
start service="":
    {{DOCKER_START}} {{service}}

# Start a service in background (or all if service is empty)
start-bg service="":
    {{DOCKER_START}} -d {{service}}

# Start a service without build (or all if service is empty)
start-nobuild service="":
    {{DOCKER_START}} --no-build {{service}}

# Start a service with --no-cache build (or all if service is empty)
start-nocache service="":
    {{DOCKER_START}} --no-cache {{service}}

# Start and attach to a service interactively (shell or command)
interactive service command="":
    @if [ -z "{{service}}" ]; then \
        echo "Set service=<api|dagster|streamlit|jupyter>"; \
        exit 2; \
    fi
    @if [ -n "{{command}}" ]; then \
        {{DOCKER_START}} -i -c "{{command}}" {{service}}; \
    else \
        {{DOCKER_START}} -i {{service}}; \
    fi

# -----------------------------------------------------------------------------
# Direct docker compose helpers
# -----------------------------------------------------------------------------

# Show compose status
status:
    docker compose -f {{COMPOSE_FILE}} ps

# Tail logs (all services or a single service)
logs service="":
    @if [ -n "{{service}}" ]; then \
        docker compose -f {{COMPOSE_FILE}} logs -f {{service}}; \
    else \
        docker compose -f {{COMPOSE_FILE}} logs -f; \
    fi

# Build images (all or a single service)
build service="":
    @if [ -n "{{service}}" ]; then \
        docker compose -f {{COMPOSE_FILE}} build {{service}}; \
    else \
        docker compose -f {{COMPOSE_FILE}} build; \
    fi

# Build images with --no-cache (all or a single service)
build-nocache service="":
    @if [ -n "{{service}}" ]; then \
        docker compose -f {{COMPOSE_FILE}} build --no-cache {{service}}; \
    else \
        docker compose -f {{COMPOSE_FILE}} build --no-cache; \
    fi

# Stop services (all or a single service)
stop service="":
    @if [ -n "{{service}}" ]; then \
        docker compose -f {{COMPOSE_FILE}} stop {{service}}; \
    else \
        docker compose -f {{COMPOSE_FILE}} stop; \
    fi

# Bring down all services and networks
compose-down:
    docker compose -f {{COMPOSE_FILE}} down

# Restart services (all or a single service)
restart service="":
    @if [ -n "{{service}}" ]; then \
        docker compose -f {{COMPOSE_FILE}} restart {{service}}; \
    else \
        docker compose -f {{COMPOSE_FILE}} restart; \
    fi

# Open a shell in a running service
shell service:
    docker compose -f {{COMPOSE_FILE}} exec {{service}} sh

# Execute a command in a running service
exec service command:
    docker compose -f {{COMPOSE_FILE}} exec {{service}} sh -lc "{{command}}"

# -----------------------------------------------------------------------------
# Convenience aliases
# -----------------------------------------------------------------------------

# Start all services in background
up:
    {{DOCKER_START}} -d

# Stop and remove containers
down: compose-down
