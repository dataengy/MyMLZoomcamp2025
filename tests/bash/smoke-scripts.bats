#!/usr/bin/env bats
# Smoke tests: project scripts — help flags, dry-runs, basic invocations.
# Nothing here touches external services or builds Docker images.

# ---------------------------------------------------------------------------- #
# Helpers
# Set PROJECT_ROOT env var before running, or run bats from the project root:
#   PROJECT_ROOT=$(pwd) bats tests/bash/smoke-*.bats
# ---------------------------------------------------------------------------- #

: "${PROJECT_ROOT:=$(pwd)}"

# ---------------------------------------------------------------------------- #
# docker-start.sh — CLI help
# ---------------------------------------------------------------------------- #

@test "docker-start.sh --help exits 0 and shows usage" {
    run bash "$PROJECT_ROOT/docker-start.sh" --help
    [[ $status -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--menu"* ]]
    [[ "$output" == *"--interactive"* ]]
}

# ---------------------------------------------------------------------------- #
# doctor health-check — help flag and run
# ---------------------------------------------------------------------------- #

@test "health-check doctor script --help exits 0" {
    run bash "$PROJECT_ROOT/scripts/doctor/loc-02-project-health-check.sh" --help
    [[ $status -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--fix"* ]]
}

@test "health-check doctor script runs and reports status" {
    run bash "$PROJECT_ROOT/scripts/doctor/loc-02-project-health-check.sh" --verbose
    # exit 0 = all ok, exit 1 = issues found — both valid for a smoke test.
    [[ $status -eq 0 ]] || [[ $status -eq 1 ]]
    [[ "$output" == *"Project Health Check"* ]]
}

# ---------------------------------------------------------------------------- #
# Makefile — target existence via dry-run (no side-effects)
# ---------------------------------------------------------------------------- #

@test "make train --dry-run includes PYTHONPATH=src" {
    run make -n train -C "$PROJECT_ROOT"
    [[ $status -eq 0 ]]
    [[ "$output" == *"PYTHONPATH=src"* ]]
}

@test "make serve --dry-run references uvicorn" {
    run make -n serve -C "$PROJECT_ROOT"
    [[ $status -eq 0 ]]
    [[ "$output" == *"uvicorn"* ]]
}

@test "make test --dry-run references pytest" {
    run make -n test -C "$PROJECT_ROOT"
    [[ $status -eq 0 ]]
    [[ "$output" == *"pytest"* ]]
}

@test "make streamlit --dry-run references streamlit" {
    run make -n streamlit -C "$PROJECT_ROOT"
    [[ $status -eq 0 ]]
    [[ "$output" == *"streamlit"* ]]
}

# ---------------------------------------------------------------------------- #
# pyproject.toml — sanity checks
# ---------------------------------------------------------------------------- #

@test "pyproject.toml declares python >= 3.13" {
    run grep -q 'requires-python.*>=3.13' "$PROJECT_ROOT/pyproject.toml"
    [[ $status -eq 0 ]]
}

@test "pyproject.toml registers integration marker" {
    run grep -q 'integration' "$PROJECT_ROOT/pyproject.toml"
    [[ $status -eq 0 ]]
}

# ---------------------------------------------------------------------------- #
# config/config.yml — basic YAML structure
# ---------------------------------------------------------------------------- #

@test "config.yml contains logging section" {
    run grep -q '^logging:' "$PROJECT_ROOT/config/config.yml"
    [[ $status -eq 0 ]]
}

@test "config.yml specifies a log file path" {
    run grep -q 'path:' "$PROJECT_ROOT/config/config.yml"
    [[ $status -eq 0 ]]
}
