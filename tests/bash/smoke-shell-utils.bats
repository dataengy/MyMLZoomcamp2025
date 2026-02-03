#!/usr/bin/env bats
# Smoke tests: shell utility functions (log4bash, utils)
# Sources scripts and exercises core helpers to catch regressions.

# ---------------------------------------------------------------------------- #
# Helpers
# Set PROJECT_ROOT env var before running, or run bats from the project root:
#   PROJECT_ROOT=$(pwd) bats tests/bash/smoke-*.bats
# ---------------------------------------------------------------------------- #

: "${PROJECT_ROOT:=$(pwd)}"
LOG4BASH="$PROJECT_ROOT/scripts/utils/log4bash.sh"
LOG4SH="$PROJECT_ROOT/scripts/utils/log4sh.sh"
UTILS="$PROJECT_ROOT/scripts/utils/utils.sh"

# ---------------------------------------------------------------------------- #
# log4bash.sh — logging primitives
# ---------------------------------------------------------------------------- #

@test "log4bash.sh is sourceable" {
    run bash -c "source '$LOG4BASH'"
    [[ $status -eq 0 ]]
}

@test "log_level_num returns expected numeric levels" {
    run bash -c "
        source '$LOG4BASH'
        [[ \$(log_level_num DEBUG) -eq 10 ]]
        [[ \$(log_level_num INFO)  -eq 20 ]]
        [[ \$(log_level_num WARN)  -eq 30 ]]
        [[ \$(log_level_num ERROR) -eq 40 ]]
    "
    [[ $status -eq 0 ]]
}

@test "log_level_num defaults unknown level to 20" {
    run bash -c "
        source '$LOG4BASH'
        [[ \$(log_level_num UNKNOWN) -eq 20 ]]
    "
    [[ $status -eq 0 ]]
}

@test "log_info outputs short format with emoji" {
    run env LOG_LEVEL=DEBUG bash -c "source '$LOG4BASH'; log_info 'hello world'"
    [[ $status -eq 0 ]]
    [[ "$output" =~ ^[0-9]{2}/[0-9]{2}/[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}:[0-9]{2} ]]
    [[ "$output" == *"ℹ"* ]]
    [[ "$output" == *"hello world"* ]]
}

@test "log_debug is suppressed when LOG_LEVEL=INFO" {
    run env LOG_LEVEL=INFO bash -c "source '$LOG4BASH'; set +e; log_debug 'should not appear'; true"
    [[ "$output" != *"should not appear"* ]]
}

@test "log_debug is visible when LOG_LEVEL=DEBUG" {
    run env LOG_LEVEL=DEBUG bash -c "source '$LOG4BASH'; log_debug 'visible now'"
    [[ $status -eq 0 ]]
    [[ "$output" == *"visible now"* ]]
}

@test "log_warn writes to stderr and includes WARN label" {
    run env LOG_LEVEL=DEBUG bash -c "source '$LOG4BASH'; log_warn 'watch out' 2>&1"
    [[ $status -eq 0 ]]
    [[ "$output" == *"⚠"* ]]
    [[ "$output" == *"watch out"* ]]
}

@test "log_error writes to stderr and includes ERROR label" {
    run env LOG_LEVEL=DEBUG bash -c "source '$LOG4BASH'; log_error 'bad thing' 2>&1"
    [[ $status -eq 0 ]]
    [[ "$output" == *"❌"* ]]
    [[ "$output" == *"bad thing"* ]]
}

@test "log4sh.sh is sourceable" {
    run sh -c ". '$LOG4SH'"
    [[ $status -eq 0 ]]
}

@test "log4sh info outputs short format with emoji" {
    run env LOG_LEVEL=INFO sh -c ". '$LOG4SH'; log_info 'sh hello'"
    [[ $status -eq 0 ]]
    [[ "$output" =~ ^[0-9]{2}/[0-9]{2}/[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}:[0-9]{2} ]]
    [[ "$output" == *"ℹ"* ]]
    [[ "$output" == *"sh hello"* ]]
}

# ---------------------------------------------------------------------------- #
# utils.sh — have(), say(), log(), warn(), fail()
# ---------------------------------------------------------------------------- #

@test "utils.sh is sourceable" {
    run bash -c "source '$UTILS'"
    [[ $status -eq 0 ]]
}

@test "have() returns 0 for an existing command (bash)" {
    run bash -c "source '$UTILS'; have bash"
    [[ $status -eq 0 ]]
}

@test "have() returns non-zero for a non-existent command" {
    run bash -c "source '$UTILS'; have this_command_does_not_exist_xyz"
    [[ $status -ne 0 ]]
}

@test "say() outputs its argument to stdout" {
    run bash -c "source '$UTILS'; say 'ping pong'"
    [[ $status -eq 0 ]]
    [[ "$output" == "ping pong" ]]
}

@test "log() outputs INFO-style message" {
    run bash -c "source '$UTILS'; log 'checking in'"
    [[ $status -eq 0 ]]
    [[ "$output" == *"checking in"* ]]
}

@test "fail() exits with code 1" {
    run bash -c "source '$UTILS'; fail 'intentional failure'"
    [[ $status -eq 1 ]]
    [[ "$output" == *"intentional failure"* ]]
}

# ---------------------------------------------------------------------------- #
# log_enabled threshold logic
# ---------------------------------------------------------------------------- #

@test "log_enabled returns true when threshold is met" {
    run env LOG_LEVEL=DEBUG bash -c "source '$LOG4BASH'; log_enabled INFO"
    [[ $status -eq 0 ]]
}

@test "log_enabled returns false when threshold is not met" {
    run env LOG_LEVEL=WARN bash -c "source '$LOG4BASH'; set +e; log_enabled DEBUG"
    [[ $status -ne 0 ]]
}
