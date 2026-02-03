#!/usr/bin/env bash
#
# Doctor script: Project health check
# Checks common project issues and suggests fixes
#
# Usage:
#   ./loc-02-project-health-check.sh [--fix] [--verbose]
#
# Examples:
#   ./loc-02-project-health-check.sh           # Check only
#   ./loc-02-project-health-check.sh --fix     # Check and auto-fix issues
#   ./loc-02-project-health-check.sh --verbose # Detailed output
#

set -euo pipefail

# Source utilities if available
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT=$(cd "$SCRIPT_DIR/../.." && pwd)
UTILS_PATH="$PROJECT_ROOT/scripts/utils/utils.sh"

if [[ -f "$UTILS_PATH" ]]; then
  # shellcheck source=../utils/utils.sh
  source "$UTILS_PATH"
fi

# Colors
COLOR_RESET='\033[0m'
COLOR_RED='\033[31m'
COLOR_GREEN='\033[32m'
COLOR_YELLOW='\033[33m'
COLOR_BLUE='\033[34m'
COLOR_CYAN='\033[36m'

# Logging
say() { printf "%b\n" "$*"; }
log() { say "[${COLOR_BLUE}INFO${COLOR_RESET}] $*"; }
warn() { say "[${COLOR_YELLOW}WARN${COLOR_RESET}] $*"; }
error() { say "[${COLOR_RED}ERROR${COLOR_RESET}] $*"; }
success() { say "[${COLOR_GREEN}OK${COLOR_RESET}] $*"; }

# Options
AUTO_FIX=false
VERBOSE=false
ISSUES_FOUND=0

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --fix)
      AUTO_FIX=true
      shift
      ;;
    --verbose|-v)
      VERBOSE=true
      shift
      ;;
    -h|--help)
      say "Usage: $0 [--fix] [--verbose]"
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      exit 1
      ;;
  esac
done

say "${COLOR_BLUE}=== Project Health Check ===${COLOR_RESET}"
say "Project: ${COLOR_CYAN}${PROJECT_ROOT}${COLOR_RESET}"
say "Auto-fix: ${COLOR_CYAN}${AUTO_FIX}${COLOR_RESET}"
say ""

# Change to project root
cd "$PROJECT_ROOT"

# Check 1: Git repository
log "Checking git repository..."
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  error "Not a git repository"
  ((ISSUES_FOUND++))
else
  success "Git repository OK"
fi

# Check 2: uv.lock file
log "Checking uv.lock..."
if [[ ! -f "uv.lock" ]]; then
  warn "uv.lock file not found"
  if [[ "$AUTO_FIX" == "true" ]]; then
    log "Generating uv.lock..."
    if command -v uv >/dev/null 2>&1; then
      uv lock
      success "Generated uv.lock"
    else
      error "uv not installed, cannot generate lock file"
      ((ISSUES_FOUND++))
    fi
  else
    error "Run 'uv lock' to create it"
    ((ISSUES_FOUND++))
  fi
elif ! git ls-files --error-unmatch uv.lock >/dev/null 2>&1; then
  warn "uv.lock exists but not tracked by git"

  # Check if it's in .git/info/exclude
  if git check-ignore -q uv.lock; then
    exclude_file=$(git check-ignore -v uv.lock | cut -d: -f1)
    warn "uv.lock is excluded by: $exclude_file"

    if [[ "$AUTO_FIX" == "true" ]]; then
      if [[ "$exclude_file" == ".git/info/exclude" ]]; then
        log "Removing uv.lock from .git/info/exclude..."
        sed -i.bak '/^\/uv\.lock$/d' .git/info/exclude
        git add uv.lock
        success "Added uv.lock to git"
      else
        error "Cannot auto-fix: uv.lock excluded in $exclude_file"
        ((ISSUES_FOUND++))
      fi
    else
      error "Run 'git add uv.lock' to track it"
      ((ISSUES_FOUND++))
    fi
  else
    if [[ "$AUTO_FIX" == "true" ]]; then
      git add uv.lock
      success "Added uv.lock to git"
    else
      warn "Run 'git add uv.lock' to track it"
      ((ISSUES_FOUND++))
    fi
  fi
else
  success "uv.lock tracked by git"
fi

# Check 3: Python environment
log "Checking Python environment..."
if command -v python >/dev/null 2>&1; then
  python_version=$(python --version 2>&1 | awk '{print $2}')
  success "Python $python_version installed"

  # Check if version matches pyproject.toml requirement
  if [[ -f "pyproject.toml" ]]; then
    required_version=$(grep "requires-python" pyproject.toml | sed -E 's/.*">=([0-9.]+)".*/\1/')
    if [[ -n "$required_version" ]]; then
      if [[ "$VERBOSE" == "true" ]]; then
        log "Required Python: >=$required_version"
      fi
    fi
  fi
else
  error "Python not found"
  ((ISSUES_FOUND++))
fi

# Check 4: uv package manager
log "Checking uv package manager..."
if command -v uv >/dev/null 2>&1; then
  uv_version=$(uv --version | awk '{print $2}')
  success "uv $uv_version installed"
else
  warn "uv not installed"
  if [[ "$AUTO_FIX" == "true" ]]; then
    log "Installing uv..."
    if command -v pip >/dev/null 2>&1; then
      pip install uv
      success "Installed uv"
    else
      error "pip not available, cannot install uv"
      ((ISSUES_FOUND++))
    fi
  else
    warn "Run 'pip install uv' to install it"
    ((ISSUES_FOUND++))
  fi
fi

# Check 5: Dependencies sync
if command -v uv >/dev/null 2>&1 && [[ -f "uv.lock" ]]; then
  log "Checking dependencies sync..."
  if [[ -f "pyproject.toml" ]]; then
    # Check if .venv exists
    if [[ ! -d ".venv" ]]; then
      warn "Virtual environment not found"
      if [[ "$AUTO_FIX" == "true" ]]; then
        log "Creating virtual environment..."
        uv sync
        success "Virtual environment created"
      else
        warn "Run 'uv sync' to create it"
        ((ISSUES_FOUND++))
      fi
    else
      success "Virtual environment exists"
    fi
  fi
fi

# Check 6: Git branch sync
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  log "Checking git branch sync..."
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  # Check if remote exists
  if git remote | grep -q "origin"; then
    # Fetch remote (quietly)
    git fetch origin >/dev/null 2>&1 || true

    upstream="origin/$current_branch"
    if git rev-parse --verify "$upstream" >/dev/null 2>&1; then
      rev_list_output=$(git rev-list --left-right --count "$upstream...$current_branch" 2>/dev/null || echo "0 0")
      behind_count=$(echo "$rev_list_output" | awk '{print $1}')
      ahead_count=$(echo "$rev_list_output" | awk '{print $2}')

      if [[ "$behind_count" -eq 0 ]] && [[ "$ahead_count" -eq 0 ]]; then
        success "Branch '$current_branch' in sync with origin"
      elif [[ "$behind_count" -gt 0 ]]; then
        warn "Branch '$current_branch' is behind origin by $behind_count commit(s)"
        if [[ "$AUTO_FIX" == "true" ]]; then
          log "Use 'scripts/doctor/loc-01-git-sync-push.sh' to sync"
        fi
        ((ISSUES_FOUND++))
      else
        warn "Branch '$current_branch' ahead of origin by $ahead_count commit(s)"
        if [[ "$VERBOSE" == "true" ]]; then
          log "Push with: git push origin $current_branch"
        fi
      fi
    else
      warn "Remote branch '$upstream' not found (new branch?)"
    fi
  else
    warn "No 'origin' remote configured"
  fi
fi

# Check 7: Uncommitted changes
log "Checking for uncommitted changes..."
if git diff-index --quiet HEAD 2>/dev/null && git diff-files --quiet 2>/dev/null; then
  success "No uncommitted changes"
else
  warn "You have uncommitted changes"
  if [[ "$VERBOSE" == "true" ]]; then
    git status --short
  fi
fi

# Check 8: Required files
log "Checking required project files..."
required_files=(
  "pyproject.toml"
  "README.md"
  "Makefile"
  ".gitignore"
)

for file in "${required_files[@]}"; do
  if [[ -f "$file" ]]; then
    if [[ "$VERBOSE" == "true" ]]; then
      success "  $file exists"
    fi
  else
    warn "  Missing: $file"
    ((ISSUES_FOUND++))
  fi
done

# Summary
say ""
say "${COLOR_BLUE}=== Summary ===${COLOR_RESET}"
if [[ $ISSUES_FOUND -eq 0 ]]; then
  say "${COLOR_GREEN}✓ All checks passed!${COLOR_RESET}"
  exit 0
else
  say "${COLOR_YELLOW}⚠ Found $ISSUES_FOUND issue(s)${COLOR_RESET}"
  if [[ "$AUTO_FIX" == "false" ]]; then
    say ""
    say "Run with ${COLOR_CYAN}--fix${COLOR_RESET} to automatically fix some issues"
  fi
  exit 1
fi
