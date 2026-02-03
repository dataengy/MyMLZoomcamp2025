#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PYTHON_VERSION="${PYTHON_VERSION:-3.13}"
UV_SYNC_FLAGS="${UV_SYNC_FLAGS:---frozen}"
ALLOW_DIRENV="${ALLOW_DIRENV:-0}"
RUN_DIR="${RUN_DIR:-$PROJECT_ROOT/.run}"
export UV_PROJECT_ENVIRONMENT="${UV_PROJECT_ENVIRONMENT:-$RUN_DIR/.venv}"

# shellcheck disable=SC1091
. "$PROJECT_ROOT/scripts/utils/utils.sh"

ensure_path_for_uv() {
  if have uv; then
    return
  fi
  if [ -x "$HOME/.local/bin/uv" ]; then
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

install_tools_macos() {
  if ! have brew; then
    fail "Homebrew not found. Install it from https://brew.sh and re-run."
  fi
  brew install direnv just uv
}

install_tools_apt() {
  sudo apt-get update
  sudo apt-get install -y direnv just curl
  if ! have uv; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
}

install_tools() {
  local os
  os="$(uname -s)"
  case "$os" in
    Darwin)
      install_tools_macos
      ;;
    Linux)
      if have apt-get; then
        install_tools_apt
      else
        fail "Unsupported Linux package manager. Install direnv, just, and uv manually."
      fi
      ;;
    *)
      fail "Unsupported OS: $os"
      ;;
  esac
}

main() {
  install_tools
  ensure_path_for_uv

  if ! have uv; then
    fail "uv not found on PATH after installation."
  fi

  mkdir -p "$RUN_DIR"/{reports,logs,dagster}
  (cd "$PROJECT_ROOT" && uv python install "$PYTHON_VERSION")
  # shellcheck disable=SC2086
  (cd "$PROJECT_ROOT" && uv sync $UV_SYNC_FLAGS)

  if [ -f "$PROJECT_ROOT/.envrc" ]; then
    if [ "$ALLOW_DIRENV" = "1" ]; then
      if have direnv; then
        (cd "$PROJECT_ROOT" && direnv allow)
      else
        warn "direnv not found; skipping direnv allow."
      fi
    else
      warn "Skipping direnv allow. Run 'ALLOW_DIRENV=1 ./scripts/setup.sh' or 'direnv allow' manually."
    fi
  fi

  log "Setup complete."
}

main "$@"
