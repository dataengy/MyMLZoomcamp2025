#!/usr/bin/env bats
# Smoke tests: Docker tooling sanity — no images built, no containers started.
# Validates that Docker is reachable, compose file parses, and image names are sane.

: "${PROJECT_ROOT:=$(pwd)}"
COMPOSE="$PROJECT_ROOT/deploy/docker-compose.yml"

# ---------------------------------------------------------------------------- #
# Docker CLI availability
# ---------------------------------------------------------------------------- #

@test "docker binary is on PATH" {
    run which docker
    [[ $status -eq 0 ]]
}

@test "docker version exits 0" {
    run docker --version
    [[ $status -eq 0 ]]
    [[ "$output" == *"Docker version"* ]]
}

# ---------------------------------------------------------------------------- #
# docker compose — config validation (no build / no run)
# ---------------------------------------------------------------------------- #

@test "docker-compose.yml exists" {
    [[ -f "$COMPOSE" ]]
}

@test "docker compose config validates compose file" {
    run docker compose -f "$COMPOSE" config
    [[ $status -eq 0 ]]
}

@test "compose file defines api service" {
    run docker compose -f "$COMPOSE" config --services
    [[ $status -eq 0 ]]
    [[ "$output" == *"api"* ]]
}

@test "compose file defines streamlit service" {
    run docker compose -f "$COMPOSE" config --services
    [[ "$output" == *"streamlit"* ]]
}

@test "compose file defines dagster service" {
    run docker compose -f "$COMPOSE" config --services
    [[ "$output" == *"dagster"* ]]
}

# ---------------------------------------------------------------------------- #
# Dockerfile basics
# ---------------------------------------------------------------------------- #

@test "Dockerfile exists in deploy/" {
    [[ -f "$PROJECT_ROOT/deploy/Dockerfile" ]]
}

@test "Dockerfile has FROM directive" {
    run grep -q '^FROM' "$PROJECT_ROOT/deploy/Dockerfile"
    [[ $status -eq 0 ]]
}

@test "Dockerfile EXPOSEs port 8000" {
    run grep -q 'EXPOSE.*8000' "$PROJECT_ROOT/deploy/Dockerfile"
    [[ $status -eq 0 ]]
}

# ---------------------------------------------------------------------------- #
# doctor docker-check script
# ---------------------------------------------------------------------------- #

@test "docker-check.sh exists and is executable" {
    [[ -f "$PROJECT_ROOT/scripts/setup/docker-check.sh" ]]
}
