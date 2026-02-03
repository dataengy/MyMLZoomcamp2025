#!/usr/bin/env bash
set -euo pipefail

# Start Dagster web UI for pipeline management.
# Uses 'dg' CLI if available, falls back to 'dagster'.

HOST="0.0.0.0"
PORT="3000"
MODULE="dags"

usage() {
  cat <<'USAGE'
Usage: scripts/dagster/start_dagster.sh [options]

Options:
  -h, --host    Host to bind (default: 0.0.0.0)
  -p, --port    Port to bind (default: 3000)
  -m, --module  Dagster module to load (default: dags)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --host)
      HOST="${2:-}"
      shift 2
      ;;
    -p | --port)
      PORT="${2:-}"
      shift 2
      ;;
    -m | --module)
      MODULE="${2:-}"
      shift 2
      ;;
    --help | -?)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

ROOT_DIR="$(pwd)"
DAGSTER_HOME_DIR="${ROOT_DIR}/.run/dagster"
mkdir -p "${DAGSTER_HOME_DIR}"

TEMPLATE_PATH="${ROOT_DIR}/config/dagster.yaml-template"
INSTANCE_CONFIG="${DAGSTER_HOME_DIR}/dagster.yaml"
if [[ ! -f "${INSTANCE_CONFIG}" && -f "${TEMPLATE_PATH}" ]]; then
  cp "${TEMPLATE_PATH}" "${INSTANCE_CONFIG}"
fi

if ! uv run python -c "import dagster_webserver" >/dev/null 2>&1; then
  echo "Missing dagster-webserver. Syncing deps..."
  uv sync
fi

if uv run python -c "import shutil; raise SystemExit(0 if shutil.which('dg') else 1)" >/dev/null 2>&1; then
  DAGSTER_HOME="${DAGSTER_HOME_DIR}" PYTHONPATH=src uv run dg dev -m "${MODULE}" --host "${HOST}" --port "${PORT}"
else
  DAGSTER_HOME="${DAGSTER_HOME_DIR}" PYTHONPATH=src uv run dagster dev -m "${MODULE}" --host "${HOST}" --port "${PORT}"
fi
