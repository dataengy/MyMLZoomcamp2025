#!/usr/bin/env sh

if [ -n "${BASH_VERSION:-}" ]; then
  # shellcheck disable=SC2128,SC3028
  SCRIPT_DIR=$(CDPATH="" cd -- "$(dirname -- "${BASH_SOURCE}")" && pwd)
else
  SCRIPT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
fi
INTERNAL_DIR="$SCRIPT_DIR/_internal"
LOG_IMPL=${LOG_IMPL:-}

if [ -n "${BASH_VERSION:-}" ] && [ "${LOG_IMPL}" != "sh" ] && [ -f "$INTERNAL_DIR/log4bash.sh" ]; then
  # shellcheck source=/dev/null
  . "$INTERNAL_DIR/log4bash.sh"
elif [ -f "$INTERNAL_DIR/log4sh.sh" ]; then
  # shellcheck source=/dev/null
  . "$INTERNAL_DIR/log4sh.sh"
fi
