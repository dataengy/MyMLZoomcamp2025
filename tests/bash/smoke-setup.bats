#!/usr/bin/env bats
# Smoke tests: setup script dry-run

: "${PROJECT_ROOT:=$(cd "$(dirname "$BATS_TEST_FILE")/../../" && pwd)}"

@test "setup.sh --dry-run exits 0" {
    run bash "$PROJECT_ROOT/scripts/setup/setup.sh" --dry-run
    [[ $status -eq 0 ]]
    [[ "$output" == *"Dry run"* ]]
}
