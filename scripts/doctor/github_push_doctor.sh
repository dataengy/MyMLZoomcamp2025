#!/usr/bin/env bash
set -euo pipefail

COLOR_RESET='\033[0m'
COLOR_RED='\033[31m'
COLOR_GREEN='\033[32m'
COLOR_YELLOW='\033[33m'
COLOR_BLUE='\033[34m'

say() { printf "%b\n" "$*"; }

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  say "${COLOR_RED}Not inside a git repository.${COLOR_RESET}"
  exit 1
fi

remote_name=${1:-origin}

say "${COLOR_BLUE}GitHub push doctor${COLOR_RESET}"

if ! git remote get-url "$remote_name" >/dev/null 2>&1; then
  say "${COLOR_RED}Remote '$remote_name' not found.${COLOR_RESET}"
  say "Add one with: git remote add $remote_name <url>"
  exit 1
fi

remote_url=$(git remote get-url "$remote_name")
current_branch=$(git rev-parse --abbrev-ref HEAD)

say "Remote: ${remote_name}"
say "URL:    ${remote_url}"
say "Branch: ${current_branch}"

say ""
read -r -p "Test GitHub SSH auth (ssh -T git@github.com)? [y/N] " do_ssh
if [[ ${do_ssh,,} == "y" ]]; then
  say "Running: ssh -T git@github.com"
  if ssh -T git@github.com 2>&1 | tee /tmp/github_ssh_check.txt; then
    say "${COLOR_GREEN}SSH test completed.${COLOR_RESET}"
  else
    say "${COLOR_YELLOW}SSH test failed. If you see 'Permission denied', configure SSH keys.${COLOR_RESET}"
  fi
fi

say ""
read -r -p "Attempt to verify remote exists (git ls-remote)? [y/N] " do_ls
if [[ ${do_ls,,} == "y" ]]; then
  say "Running: git ls-remote $remote_name"
  if git ls-remote "$remote_name" >/dev/null 2>&1; then
    say "${COLOR_GREEN}Remote is reachable.${COLOR_RESET}"
  else
    say "${COLOR_RED}Remote not reachable.${COLOR_RESET}"
  fi
fi

say ""
read -r -p "Update remote URL? [y/N] " do_update
if [[ ${do_update,,} == "y" ]]; then
  read -r -p "Enter new URL: " new_url
  if [[ -n "$new_url" ]]; then
    git remote set-url "$remote_name" "$new_url"
    say "${COLOR_GREEN}Updated $remote_name URL.${COLOR_RESET}"
  else
    say "${COLOR_YELLOW}No URL provided; skipping.${COLOR_RESET}"
  fi
fi

say ""
read -r -p "Push current branch to $remote_name? [y/N] " do_push
if [[ ${do_push,,} == "y" ]]; then
  say "Checking if local branch is behind $remote_name/$current_branch"
  if git fetch "$remote_name" >/dev/null 2>&1; then
    upstream="${remote_name}/${current_branch}"
    if git rev-parse --verify "$upstream" >/dev/null 2>&1; then
      behind_ahead=$(git rev-list --left-right --count "$upstream...$current_branch")
      behind_count=${behind_ahead%% *}
      ahead_count=${behind_ahead##* }
      if [[ "$behind_count" -gt 0 ]]; then
        say "${COLOR_YELLOW}Your branch is behind by $behind_count commit(s) (ahead by $ahead_count).${COLOR_RESET}"
        read -r -p "Sync with $upstream before pushing? [y/N] " do_sync_first
        if [[ ${do_sync_first,,} == "y" ]]; then
          read -r -p "Integrate with rebase (r) or merge (m)? [r/M] " sync_mode
          if [[ ${sync_mode,,} == "r" ]]; then
            say "Running: git rebase $upstream"
            if git rebase "$upstream"; then
              say "${COLOR_GREEN}Rebase complete.${COLOR_RESET}"
            else
              say "${COLOR_RED}Rebase failed. Resolve conflicts, then run: git rebase --continue${COLOR_RESET}"
              exit 1
            fi
          else
            say "Running: git merge $upstream"
            if git merge "$upstream"; then
              say "${COLOR_GREEN}Merge complete.${COLOR_RESET}"
            else
              say "${COLOR_RED}Merge failed. Resolve conflicts, then commit the merge (or git merge --continue).${COLOR_RESET}"
              exit 1
            fi
          fi
        fi
      fi
    fi
  fi
  say "Running: git push $remote_name $current_branch"
  push_log=$(mktemp)
  if git push "$remote_name" "$current_branch" 2>&1 | tee "$push_log"; then
    say "${COLOR_GREEN}Push succeeded.${COLOR_RESET}"
  else
    say "${COLOR_RED}Push failed.${COLOR_RESET}"
    if command -v rg >/dev/null 2>&1; then
      non_ff_detected=$(rg -q "non-fast-forward|tip of your current branch is behind" "$push_log" && echo "yes" || echo "no")
    else
      non_ff_detected=$(grep -E -q "non-fast-forward|tip of your current branch is behind" "$push_log" && echo "yes" || echo "no")
    fi
    if [[ "$non_ff_detected" == "yes" ]]; then
      say "${COLOR_YELLOW}Remote has new commits. Your branch is behind.${COLOR_RESET}"
      say "Typical fix: integrate remote changes, then push again."
      say "Example: git pull --rebase $remote_name $current_branch && git push $remote_name $current_branch"
      read -r -p "Attempt to sync with $remote_name/$current_branch now? [y/N] " do_sync
      if [[ ${do_sync,,} == "y" ]]; then
        say "Running: git fetch $remote_name"
        git fetch "$remote_name"
        upstream="${remote_name}/${current_branch}"
        read -r -p "Integrate with rebase (r) or merge (m)? [r/M] " sync_mode
        if [[ ${sync_mode,,} == "r" ]]; then
          say "Running: git rebase $upstream"
          if git rebase "$upstream"; then
            say "${COLOR_GREEN}Rebase complete.${COLOR_RESET}"
          else
            say "${COLOR_RED}Rebase failed. Resolve conflicts, then run: git rebase --continue${COLOR_RESET}"
            exit 1
          fi
        else
          say "Running: git merge $upstream"
          if git merge "$upstream"; then
            say "${COLOR_GREEN}Merge complete.${COLOR_RESET}"
          else
            say "${COLOR_RED}Merge failed. Resolve conflicts, then commit the merge (or git merge --continue).${COLOR_RESET}"
            exit 1
          fi
        fi
        say "Retrying: git push $remote_name $current_branch"
        if git push "$remote_name" "$current_branch"; then
          say "${COLOR_GREEN}Push succeeded.${COLOR_RESET}"
          rm -f "$push_log"
          exit 0
        else
          say "${COLOR_RED}Push failed again.${COLOR_RESET}"
        fi
      fi
    fi
    rm -f "$push_log"
    exit 1
  fi
  rm -f "$push_log"
else
  say "${COLOR_YELLOW}Push skipped.${COLOR_RESET}"
fi
