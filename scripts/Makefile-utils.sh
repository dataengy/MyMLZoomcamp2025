#!/usr/bin/env bash
set -euo pipefail

run_data() {
  local download_args=()
  local process_args=()

  if [[ -n "${DATA_TYPE:-}" ]]; then
    download_args+=("--data-type" "${DATA_TYPE}")
  fi
  if [[ -n "${DATA_YEAR:-}" ]]; then
    download_args+=("--year" "${DATA_YEAR}")
  fi
  if [[ -n "${DATA_MONTHS:-}" ]]; then
    # Space-separated months, e.g. DATA_MONTHS="1 2 3"
    download_args+=("--months" ${DATA_MONTHS})
  fi
  if [[ -n "${DATA_OUTPUT_DIR:-}" ]]; then
    download_args+=("--output-dir" "${DATA_OUTPUT_DIR}")
    process_args+=("--input-dir" "${DATA_OUTPUT_DIR}")
  fi
  if [[ -n "${DATA_SAMPLE:-}" ]]; then
    download_args+=("--sample")
  fi
  if [[ -n "${DATA_FORCE:-}" ]]; then
    download_args+=("--force")
  fi

  if [[ -n "${DATA_PROCESSED_DIR:-}" ]]; then
    process_args+=("--output-dir" "${DATA_PROCESSED_DIR}")
  fi
  if [[ -n "${DATA_SAMPLE_SIZE:-}" ]]; then
    process_args+=("--sample-size" "${DATA_SAMPLE_SIZE}")
  fi
  if [[ -n "${DATA_INPUT_FORMAT:-}" ]]; then
    process_args+=("--input-format" "${DATA_INPUT_FORMAT}")
  fi
  if [[ -n "${DATA_OUTPUT_FORMAT:-}" ]]; then
    process_args+=("--output-format" "${DATA_OUTPUT_FORMAT}")
  fi

  uv run python scripts/download_data.py "${download_args[@]}"
  uv run python scripts/process_data.py "${process_args[@]}"
}
