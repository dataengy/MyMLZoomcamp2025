#!/usr/bin/env bats
# Smoke tests: project structure integrity
# Verifies that required files, directories and config exist.

# ---------------------------------------------------------------------------- #
# Helpers
# Set PROJECT_ROOT env var before running, or run bats from the project root:
#   PROJECT_ROOT=$(pwd) bats tests/bash/smoke-*.bats
# ---------------------------------------------------------------------------- #

: "${PROJECT_ROOT:=$(pwd)}"

# ---------------------------------------------------------------------------- #
# Directory layout
# ---------------------------------------------------------------------------- #

@test "src/ directory exists" {
    [[ -d "$PROJECT_ROOT/src" ]]
}

@test "src/api/ contains main.py" {
    [[ -f "$PROJECT_ROOT/src/api/main.py" ]]
}

@test "src/training/ contains train.py and evaluate.py" {
    [[ -f "$PROJECT_ROOT/src/training/train.py" ]]
    [[ -f "$PROJECT_ROOT/src/training/evaluate.py" ]]
}

@test "src/config/ contains logging.py and paths.py" {
    [[ -f "$PROJECT_ROOT/src/config/logging.py" ]]
    [[ -f "$PROJECT_ROOT/src/config/paths.py" ]]
}

@test "src/dags/ contains definitions.py" {
    [[ -f "$PROJECT_ROOT/src/dags/definitions.py" ]]
}

@test "src/ui/ contains streamlit_app.py" {
    [[ -f "$PROJECT_ROOT/src/ui/streamlit_app.py" ]]
}

@test "config/ has config.yml and .env.demo" {
    [[ -f "$PROJECT_ROOT/config/config.yml" ]]
    [[ -f "$PROJECT_ROOT/config/.env.demo" ]]
}

@test "tests/ has unit/ and integration/ subdirectories" {
    [[ -d "$PROJECT_ROOT/tests/unit" ]]
    [[ -d "$PROJECT_ROOT/tests/integration" ]]
}

@test "scripts/tests/ has standalone test scripts" {
    [[ -f "$PROJECT_ROOT/scripts/tests/simple_data_test.py" ]]
    [[ -f "$PROJECT_ROOT/scripts/tests/simple_ml_test.py" ]]
}

@test "deploy/ has Dockerfile and docker-compose.yml" {
    [[ -f "$PROJECT_ROOT/deploy/Dockerfile" ]]
    [[ -f "$PROJECT_ROOT/deploy/docker-compose.yml" ]]
}

@test "scripts/data_tools/ has download, process, load scripts" {
    [[ -f "$PROJECT_ROOT/scripts/data_tools/download_data.py" ]]
    [[ -f "$PROJECT_ROOT/scripts/data_tools/process_data.py" ]]
    [[ -f "$PROJECT_ROOT/scripts/data_tools/load_data.py" ]]
}

@test "scripts/doctor/ has health-check script" {
    [[ -f "$PROJECT_ROOT/scripts/doctor/loc-02-project-health-check.sh" ]]
}

@test "root has Makefile, Justfile, pyproject.toml, README.md" {
    [[ -f "$PROJECT_ROOT/Makefile" ]]
    [[ -f "$PROJECT_ROOT/Justfile" ]]
    [[ -f "$PROJECT_ROOT/pyproject.toml" ]]
    [[ -f "$PROJECT_ROOT/README.md" ]]
}

@test "uv.lock is tracked by git" {
    run git -C "$PROJECT_ROOT" ls-files --error-unmatch uv.lock
    [[ $status -eq 0 ]]
}

@test ".ai/ directory has TODO.md and AGENTS.md" {
    [[ -f "$PROJECT_ROOT/.ai/TODO.md" ]]
    [[ -f "$PROJECT_ROOT/.ai/AGENTS.md" ]]
}

@test "streamlit config exists (config/ or .streamlit/)" {
    [[ -f "$PROJECT_ROOT/config/streamlit-config.toml" ]] || [[ -f "$PROJECT_ROOT/.streamlit/config.toml" ]]
}
