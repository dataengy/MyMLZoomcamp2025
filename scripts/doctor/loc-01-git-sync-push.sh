#!/usr/bin/env bash
#
# Doctor script: Git sync and push
# Handles diverged branches, automatically syncs with remote, and pushes changes
#
# Usage:
#   ./loc-01-git-sync-push.sh [remote] [branch] [--dry-run] [--auto-stash] [--rebase|--merge]
#
# Examples:
#   ./loc-01-git-sync-push.sh                    # Interactive mode
#   ./loc-01-git-sync-push.sh origin main        # Specific remote/branch
#   ./loc-01-git-sync-push.sh --dry-run          # Show what would happen
#   ./loc-01-git-sync-push.sh --auto-stash       # Auto-stash uncommitted changes
#

set -euo pipefail

# Source utilities if available
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
UTILS_PATH="$(dirname "$SCRIPT_DIR")/utils/utils.sh"
if [[ -f "$UTILS_PATH" ]]; then
  # shellcheck disable=SC1090,SC1091
  source "$UTILS_PATH"
fi

# Logging functions (fallback if utils not available)
say() { printf "%b\n" "$*"; }
log() { say "[INFO] $*"; }
warn() { say "[WARN] $*" >&2; }
fail() {
  say "[ERROR] $*" >&2
  exit 1
}

# Colors
COLOR_RESET='\033[0m'
COLOR_RED='\033[31m'
COLOR_GREEN='\033[32m'
COLOR_YELLOW='\033[33m'
COLOR_BLUE='\033[34m'
COLOR_CYAN='\033[36m'

# Default values
DRY_RUN=false
AUTO_STASH=false
SYNC_MODE="" # empty=ask, "rebase", "merge"
REMOTE=""
BRANCH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --auto-stash)
      AUTO_STASH=true
      shift
      ;;
    --rebase)
      SYNC_MODE="rebase"
      shift
      ;;
    --merge)
      SYNC_MODE="merge"
      shift
      ;;
    -h | --help)
      say "Usage: $0 [remote] [branch] [--dry-run] [--auto-stash] [--rebase|--merge]"
      exit 0
      ;;
    *)
      if [[ -z "$REMOTE" ]]; then
        REMOTE="$1"
      elif [[ -z "$BRANCH" ]]; then
        BRANCH="$1"
      else
        fail "Unknown argument: $1"
      fi
      shift
      ;;
  esac
done

# Verify we're in a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "Not inside a git repository"
fi

# Get defaults
REMOTE=${REMOTE:-origin}
BRANCH=${BRANCH:-$(git rev-parse --abbrev-ref HEAD)}

say "${COLOR_BLUE}=== Git Sync & Push Doctor ===${COLOR_RESET}"
say "Remote:   ${COLOR_CYAN}${REMOTE}${COLOR_RESET}"
say "Branch:   ${COLOR_CYAN}${BRANCH}${COLOR_RESET}"
say "Dry run:  ${COLOR_CYAN}${DRY_RUN}${COLOR_RESET}"
say ""

# Check remote exists
if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  fail "Remote '$REMOTE' not found. Available remotes: $(git remote | tr '\n' ' ')"
fi

# Fetch remote
say "${COLOR_BLUE}Step 1: Fetching from $REMOTE...${COLOR_RESET}"
if [[ "$DRY_RUN" == "false" ]]; then
  git fetch "$REMOTE" || fail "Failed to fetch from $REMOTE"
else
  say "[DRY-RUN] Would run: git fetch $REMOTE"
fi

# Check if remote branch exists
upstream="${REMOTE}/${BRANCH}"
if ! git rev-parse --verify "$upstream" >/dev/null 2>&1; then
  warn "Remote branch $upstream does not exist yet"
  say "${COLOR_YELLOW}This appears to be a new branch. Pushing...${COLOR_RESET}"
  if [[ "$DRY_RUN" == "false" ]]; then
    git push -u "$REMOTE" "$BRANCH"
    say "${COLOR_GREEN}✓ Branch pushed successfully${COLOR_RESET}"
  else
    say "[DRY-RUN] Would run: git push -u $REMOTE $BRANCH"
  fi
  exit 0
fi

# Get ahead/behind counts
say "${COLOR_BLUE}Step 2: Checking branch status...${COLOR_RESET}"

# Fix for the arithmetic bug - properly parse git rev-list output
rev_list_output=$(git rev-list --left-right --count "$upstream...$BRANCH")
behind_count=$(echo "$rev_list_output" | awk '{print $1}')
ahead_count=$(echo "$rev_list_output" | awk '{print $2}')

say "  Behind remote: ${COLOR_YELLOW}${behind_count}${COLOR_RESET} commit(s)"
say "  Ahead of remote: ${COLOR_YELLOW}${ahead_count}${COLOR_RESET} commit(s)"
say ""

# Check if we're already in sync
if [[ "$behind_count" -eq 0 ]] && [[ "$ahead_count" -eq 0 ]]; then
  say "${COLOR_GREEN}✓ Already in sync with $upstream${COLOR_RESET}"
  exit 0
fi

# If only ahead, just push
if [[ "$behind_count" -eq 0 ]] && [[ "$ahead_count" -gt 0 ]]; then
  say "${COLOR_GREEN}Branch is ahead by $ahead_count commit(s). Ready to push.${COLOR_RESET}"
  say "${COLOR_BLUE}Step 3: Pushing to $upstream...${COLOR_RESET}"
  if [[ "$DRY_RUN" == "false" ]]; then
    git push "$REMOTE" "$BRANCH"
    say "${COLOR_GREEN}✓ Push successful${COLOR_RESET}"
  else
    say "[DRY-RUN] Would run: git push $REMOTE $BRANCH"
  fi
  exit 0
fi

# We're behind - need to sync
say "${COLOR_YELLOW}Branch is behind remote by $behind_count commit(s)${COLOR_RESET}"
say "${COLOR_BLUE}Step 3: Syncing with $upstream...${COLOR_RESET}"

# Check for uncommitted changes
if ! git diff-index --quiet HEAD 2>/dev/null || ! git diff-files --quiet 2>/dev/null; then
  warn "You have uncommitted changes"
  if [[ "$AUTO_STASH" == "true" ]]; then
    say "Auto-stashing changes..."
    if [[ "$DRY_RUN" == "false" ]]; then
      git stash push -m "Auto-stash by git-sync-push doctor script" || fail "Failed to stash changes"
      say "${COLOR_GREEN}✓ Changes stashed${COLOR_RESET}"
    else
      say "[DRY-RUN] Would run: git stash push -m '...'"
    fi
    STASHED=true
  else
    say ""
    say "${COLOR_RED}Options:${COLOR_RESET}"
    say "  1. Commit your changes first"
    say "  2. Run with --auto-stash to automatically stash/unstash"
    say "  3. Manually stash: git stash"
    say ""
    fail "Cannot sync with uncommitted changes. Aborting."
  fi
else
  STASHED=false
fi

# Determine sync mode
if [[ -z "$SYNC_MODE" ]]; then
  say ""
  read -r -p "Integrate with ${COLOR_CYAN}rebase${COLOR_RESET} (r) or ${COLOR_CYAN}merge${COLOR_RESET} (m)? [r/M] " sync_choice
  if [[ "${sync_choice,,}" == "r" ]]; then
    SYNC_MODE="rebase"
  else
    SYNC_MODE="merge"
  fi
fi

# Perform sync
say ""
say "${COLOR_BLUE}Syncing with ${SYNC_MODE}...${COLOR_RESET}"

if [[ "$SYNC_MODE" == "rebase" ]]; then
  if [[ "$DRY_RUN" == "false" ]]; then
    if git rebase "$upstream"; then
      say "${COLOR_GREEN}✓ Rebase successful${COLOR_RESET}"
    else
      say "${COLOR_RED}✗ Rebase failed${COLOR_RESET}"
      say ""
      say "To resolve:"
      say "  1. Fix conflicts in the files marked by git"
      say "  2. git add <resolved-files>"
      say "  3. git rebase --continue"
      say ""
      say "Or abort with: git rebase --abort"
      exit 1
    fi
  else
    say "[DRY-RUN] Would run: git rebase $upstream"
  fi
else # merge
  if [[ "$DRY_RUN" == "false" ]]; then
    if git merge "$upstream"; then
      say "${COLOR_GREEN}✓ Merge successful${COLOR_RESET}"
    else
      say "${COLOR_RED}✗ Merge failed${COLOR_RESET}"
      say ""
      say "To resolve:"
      say "  1. Fix conflicts in the files marked by git"
      say "  2. git add <resolved-files>"
      say "  3. git commit (or git merge --continue)"
      say ""
      say "Or abort with: git merge --abort"
      exit 1
    fi
  else
    say "[DRY-RUN] Would run: git merge $upstream"
  fi
fi

# Restore stashed changes if any
if [[ "$STASHED" == "true" ]]; then
  say ""
  say "${COLOR_BLUE}Restoring stashed changes...${COLOR_RESET}"
  if [[ "$DRY_RUN" == "false" ]]; then
    if git stash pop; then
      say "${COLOR_GREEN}✓ Changes restored${COLOR_RESET}"
    else
      warn "Failed to restore stash automatically"
      say "Your changes are in: git stash list"
      say "Manually restore with: git stash pop"
    fi
  else
    say "[DRY-RUN] Would run: git stash pop"
  fi
fi

# Push
say ""
say "${COLOR_BLUE}Step 4: Pushing to $upstream...${COLOR_RESET}"
if [[ "$DRY_RUN" == "false" ]]; then
  if git push "$REMOTE" "$BRANCH"; then
    say ""
    say "${COLOR_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    say "${COLOR_GREEN}✓ Successfully synced and pushed!${COLOR_RESET}"
    say "${COLOR_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
  else
    say "${COLOR_RED}✗ Push failed${COLOR_RESET}"
    exit 1
  fi
else
  say "[DRY-RUN] Would run: git push $REMOTE $BRANCH"
  say ""
  say "[DRY-RUN] All operations completed successfully (dry-run mode)"
fi
