#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(CDPATH="" cd -- "$(dirname -- "$0")" && pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIR}/../utils/utils.sh"

URL="http://127.0.0.1:3000"
TIMEOUT="3"
RETRIES="5"
SLEEP_SECS="1"

usage() {
  cat <<'USAGE'
Usage: scripts/doctor/web-tool-check.sh [options]

Checks that a local web tool (e.g., Dagster UI) responds.

Options:
  -u, --url       URL to check (default: http://127.0.0.1:3000)
  -t, --timeout   Timeout seconds per request (default: 3)
  -r, --retries   Number of attempts (default: 5)
  -s, --sleep     Sleep seconds between attempts (default: 1)
  -h, --help      Show this help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    -u | --url)
      URL="${2:-}"
      shift 2
      ;;
    -t | --timeout)
      TIMEOUT="${2:-}"
      shift 2
      ;;
    -r | --retries)
      RETRIES="${2:-}"
      shift 2
      ;;
    -s | --sleep)
      SLEEP_SECS="${2:-}"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
done

if [[ -z "${URL}" ]]; then
  fail "URL cannot be empty."
fi

CHECK_URL="${URL}"
if [[ "${URL}" == *"0.0.0.0"* ]]; then
  warn "0.0.0.0 is a bind address; browsers should use 127.0.0.1 or localhost instead."
  CHECK_URL="${URL//0.0.0.0/127.0.0.1}"
fi

http_status() {
  local target="$1"
  if have curl; then
    curl -sS -o /dev/null -w "%{http_code}" --max-time "${TIMEOUT}" "${target}" || echo "000"
    return 0
  fi

  python3 - "${target}" "${TIMEOUT}" <<'PY'
import sys
import urllib.request

url = sys.argv[1]
timeout = float(sys.argv[2])
try:
    with urllib.request.urlopen(url, timeout=timeout) as response:
        print(response.getcode())
except Exception:
    print("000")
PY
}

log "Checking ${CHECK_URL} (retries=${RETRIES}, timeout=${TIMEOUT}s)"

attempt=1
while [[ ${attempt} -le ${RETRIES} ]]; do
  status="$(http_status "${CHECK_URL}")"
  if [[ "${status}" =~ ^[0-9]+$ ]] && [[ ${status} -ge 200 ]] && [[ ${status} -lt 400 ]]; then
    log "OK (${status}) ${CHECK_URL}"
    exit 0
  fi

  warn "Attempt ${attempt}/${RETRIES} failed (status=${status})."
  attempt=$((attempt + 1))
  sleep "${SLEEP_SECS}"
done

fail "No response from ${CHECK_URL}. If Dagster logs show 'Serving dagster-webserver on http://0.0.0.0:3000', open http://127.0.0.1:3000. Otherwise start it with 'make run-dags' or './scripts/dagster/start_dagster.sh'."
