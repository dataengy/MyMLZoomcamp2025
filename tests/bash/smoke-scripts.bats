#!/usr/bin/env bats
# Smoke tests: project scripts — help flags, dry-runs, basic invocations.
# Nothing here touches external services or builds Docker images.

# ---------------------------------------------------------------------------- #
# Helpers
# ---------------------------------------------------------------------------- #

PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILE")/../../" && pwd)"

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
# doctor health-check — help flag
# ---------------------------------------------------------------------------- #

@test "health-check doctor script --help exits 0" {
    run bash "$PROJECT_ROOT/scripts/doctor/loc-02-project-health-check.sh" --help
    [[ $status -eq 0 ]]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"--fix"* ]]
}

@test "health-check doctor script runs and reports status" {
    run bash "$PROJECT_ROOT/scripts/doctor/loc-02-project-health-check.sh" --verbose
    # Script exits 0 when all checks pass, or 1 when issues found — both are acceptable smoke outcomes.
    # What matters: it ran without crashing (exit codes 0 or 1 only).
    [[ $status -eq 0 ]] || [[ $status -eq 1 ]]
    [[ "$output" == *"Project Health Check"* ]]
}

# ---------------------------------------------------------------------------- #
# Makefile — target existence (dry-run, no side-effects)
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
# pyproject.toml — sanity checks via Python (single-line evals)
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
