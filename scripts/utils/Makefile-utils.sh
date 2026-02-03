#!/usr/bin/env bash
set -euo pipefail

LOG_LEVEL="${LOG_LEVEL:-debug}"

log_debug() {
  if [[ "${LOG_LEVEL}" == "debug" ]]; then
    echo "[DEBUG] $*"
  fi
}

log_info() {
  if [[ "${LOG_LEVEL}" == "debug" || "${LOG_LEVEL}" == "info" ]]; then
    echo "[INFO] $*"
  fi
}

log_warn() {
  echo "[WARN] $*"
}

run_data() {
  log_info "Starting data step"
  local download_args=()
  local process_args=()

  if [[ -n "${DATA_TYPE:-}" ]]; then
    download_args+=("--data-type" "${DATA_TYPE}")
    log_debug "DATA_TYPE=${DATA_TYPE}"
  fi
  if [[ -n "${DATA_YEAR:-}" ]]; then
    download_args+=("--year" "${DATA_YEAR}")
    log_debug "DATA_YEAR=${DATA_YEAR}"
  fi
  if [[ -n "${DATA_MONTHS:-}" ]]; then
    # Space-separated months, e.g. DATA_MONTHS="1 2 3"
    read -r -a data_months <<<"${DATA_MONTHS}"
    download_args+=("--months" "${data_months[@]}")
    log_debug "DATA_MONTHS=${DATA_MONTHS}"
  fi
  if [[ -n "${DATA_OUTPUT_DIR:-}" ]]; then
    download_args+=("--output-dir" "${DATA_OUTPUT_DIR}")
    process_args+=("--input-dir" "${DATA_OUTPUT_DIR}")
    log_debug "DATA_OUTPUT_DIR=${DATA_OUTPUT_DIR}"
  fi
  if [[ -n "${DATA_SAMPLE:-}" ]]; then
    download_args+=("--sample")
    log_debug "DATA_SAMPLE=1"
  fi
  if [[ -n "${DATA_FORCE:-}" ]]; then
    download_args+=("--force")
    log_debug "DATA_FORCE=1"
  fi

  if [[ -n "${DATA_PROCESSED_DIR:-}" ]]; then
    process_args+=("--output-dir" "${DATA_PROCESSED_DIR}")
    log_debug "DATA_PROCESSED_DIR=${DATA_PROCESSED_DIR}"
  fi
  if [[ -n "${DATA_SAMPLE_SIZE:-}" ]]; then
    process_args+=("--sample-size" "${DATA_SAMPLE_SIZE}")
    log_debug "DATA_SAMPLE_SIZE=${DATA_SAMPLE_SIZE}"
  fi
  if [[ -n "${DATA_INPUT_FORMAT:-}" ]]; then
    process_args+=("--input-format" "${DATA_INPUT_FORMAT}")
    log_debug "DATA_INPUT_FORMAT=${DATA_INPUT_FORMAT}"
  fi
  if [[ -n "${DATA_OUTPUT_FORMAT:-}" ]]; then
    process_args+=("--output-format" "${DATA_OUTPUT_FORMAT}")
    log_debug "DATA_OUTPUT_FORMAT=${DATA_OUTPUT_FORMAT}"
  fi

  log_info "Downloading data"
  uv run python scripts/data_tools/download_data.py "${download_args[@]}"
  log_info "Processing data"
  uv run python scripts/data_tools/process_data.py "${process_args[@]}"
  log_info "Data step complete"
}
