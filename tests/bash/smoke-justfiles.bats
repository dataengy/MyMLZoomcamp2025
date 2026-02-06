#!/usr/bin/env bats
# Smoke tests: Justfiles (dry-run) to verify recipes exist and expand correctly.

: "${PROJECT_ROOT:=$(pwd)}"

# ---------------------------------------------------------------------------- #
# scripts/setup/Justfile
# ---------------------------------------------------------------------------- #

@test "setup Justfile docker-check dry-run expands to script" {
    run just -f "$PROJECT_ROOT/scripts/setup/Justfile" --dry-run docker-check
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/setup/docker-check.sh"* ]]
}

@test "setup Justfile env-check dry-run expands to python script" {
    run just -f "$PROJECT_ROOT/scripts/setup/Justfile" --dry-run env-check
    [[ $status -eq 0 ]]
    [[ "$output" == *"env-check.py"* ]]
}

@test "setup Justfile env-render dry-run expands to python script" {
    run just -f "$PROJECT_ROOT/scripts/setup/Justfile" --dry-run env-render
    [[ $status -eq 0 ]]
    [[ "$output" == *"env-render.py"* ]]
}

@test "setup Justfile env-render-sh dry-run expands to shell script" {
    run just -f "$PROJECT_ROOT/scripts/setup/Justfile" --dry-run env-render-sh
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/setup/env-render.sh"* ]]
}

@test "setup Justfile setup dry-run expands to setup.sh" {
    run just -f "$PROJECT_ROOT/scripts/setup/Justfile" --dry-run setup
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/setup/setup.sh"* ]]
}

# ---------------------------------------------------------------------------- #
# scripts/doctor/Justfile
# ---------------------------------------------------------------------------- #

@test "doctor Justfile github-push dry-run expands to script with args" {
    run just -f "$PROJECT_ROOT/scripts/doctor/Justfile" --dry-run github-push foo bar
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/doctor/github_push_doctor.sh"* ]]
    [[ "$output" == *"foo"* ]]
    [[ "$output" == *"bar"* ]]
}

@test "doctor Justfile sync-push dry-run expands to script with args" {
    run just -f "$PROJECT_ROOT/scripts/doctor/Justfile" --dry-run sync-push origin main
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/doctor/loc-01-git-sync-push.sh"* ]]
    [[ "$output" == *"origin"* ]]
    [[ "$output" == *"main"* ]]
}

@test "doctor Justfile health-check dry-run expands to script with args" {
    run just -f "$PROJECT_ROOT/scripts/doctor/Justfile" --dry-run health-check --verbose
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/doctor/loc-02-project-health-check.sh"* ]]
    [[ "$output" == *"--verbose"* ]]
}

@test "doctor Justfile docker-check dry-run expands to script with args" {
    run just -f "$PROJECT_ROOT/scripts/doctor/Justfile" --dry-run docker-check --help
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/doctor/loc-03-docker-check.sh"* ]]
    [[ "$output" == *"--help"* ]]
}

@test "doctor Justfile test-safe dry-run expands to script with args" {
    run just -f "$PROJECT_ROOT/scripts/doctor/Justfile" --dry-run test-safe -k smoke
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/doctor/run-tests-safe.py"* ]]
    [[ "$output" == *"-k"* ]]
    [[ "$output" == *"smoke"* ]]
}

# ---------------------------------------------------------------------------- #
# scripts/claude/Justfile
# ---------------------------------------------------------------------------- #

@test "claude Justfile help dry-run prints echo lines" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run help
    [[ $status -eq 0 ]]
    [[ "$output" == *"Claude utilities (Justfile)"* ]]
}

@test "claude Justfile context dry-run expands to context.sh" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run context 3
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/context.sh"* ]]
    [[ "$output" == *"--prompts"* ]]
    [[ "$output" == *"3"* ]]
}

@test "claude Justfile install-skills dry-run expands to install_skills.sh" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run install-skills --list
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/install_skills.sh"* ]]
    [[ "$output" == *"--list"* ]]
}

@test "claude Justfile install-skills-local dry-run expands to install_skills.sh --local" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run install-skills-local
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/install_skills.sh"* ]]
    [[ "$output" == *"--local"* ]]
}

@test "claude Justfile install-skills-global dry-run expands to install_skills.sh --global" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run install-skills-global
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/install_skills.sh"* ]]
    [[ "$output" == *"--global"* ]]
}

@test "claude Justfile install-skills-list dry-run expands to install_skills.sh --list" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run install-skills-list
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/install_skills.sh"* ]]
    [[ "$output" == *"--list"* ]]
}

@test "claude Justfile install-skills-only dry-run expands to install_skills.sh --only" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run install-skills-only data-profiler
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/install_skills.sh"* ]]
    [[ "$output" == *"--only"* ]]
    [[ "$output" == *"data-profiler"* ]]
}

@test "claude Justfile install-skills-force dry-run expands to install_skills.sh --force" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run install-skills-force
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/install_skills.sh"* ]]
    [[ "$output" == *"--force"* ]]
}

@test "claude Justfile install-skills-dry-run dry-run expands to install_skills.sh --dry-run" {
    run just -f "$PROJECT_ROOT/scripts/claude/Justfile" --dry-run install-skills-dry-run
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/claude/install_skills.sh"* ]]
    [[ "$output" == *"--dry-run"* ]]
}

# ---------------------------------------------------------------------------- #
# scripts/codex/Justfile
# ---------------------------------------------------------------------------- #

@test "codex Justfile help dry-run prints echo lines" {
    run just -f "$PROJECT_ROOT/scripts/codex/Justfile" --dry-run help
    [[ $status -eq 0 ]]
    [[ "$output" == *"Codex utilities (Justfile)"* ]]
}

@test "codex Justfile install-skills dry-run expands to install_local_skills.sh" {
    run just -f "$PROJECT_ROOT/scripts/codex/Justfile" --dry-run install-skills --list
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/codex/install_local_skills.sh"* ]]
    [[ "$output" == *"--list"* ]]
}

@test "codex Justfile install-skills-force dry-run expands to install_local_skills.sh --force" {
    run just -f "$PROJECT_ROOT/scripts/codex/Justfile" --dry-run install-skills-force
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/codex/install_local_skills.sh"* ]]
    [[ "$output" == *"--force"* ]]
}

# ---------------------------------------------------------------------------- #
# .ai/.codex/Justfile
# ---------------------------------------------------------------------------- #

@test "ai/codex Justfile help dry-run prints echo lines" {
    run just -f "$PROJECT_ROOT/.ai/.codex/Justfile" --dry-run help
    [[ $status -eq 0 ]]
    [[ "$output" == *"Codex local skill helpers"* ]]
}

@test "ai/codex Justfile list-local dry-run references local skills dir" {
    run just -f "$PROJECT_ROOT/.ai/.codex/Justfile" --dry-run list-local
    [[ $status -eq 0 ]]
    [[ "$output" == *".ai/.codex/skills"* ]]
}

@test "ai/codex Justfile install-local dry-run expands to install_local_skills.sh" {
    run just -f "$PROJECT_ROOT/.ai/.codex/Justfile" --dry-run install-local --list
    [[ $status -eq 0 ]]
    [[ "$output" == *"scripts/codex/install_local_skills.sh"* ]]
    [[ "$output" == *"--list"* ]]
}

@test "ai/codex Justfile package-all dry-run references package_skill.py" {
    run just -f "$PROJECT_ROOT/.ai/.codex/Justfile" --dry-run package-all
    [[ $status -eq 0 ]]
    [[ "$output" == *".ai/.codex/scripts/package_skill.py"* ]]
}
