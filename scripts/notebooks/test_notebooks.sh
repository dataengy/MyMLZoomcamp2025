#!/usr/bin/env bash
# Test notebook execution with pytest and nbval

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "==> Testing notebook execution with nbval..."
uv run pytest --nbval notebooks/ -v \
  --ignore=notebooks/.ipynb_checkpoints \
  --ignore=notebooks/templates \
  "$@"

echo "✓ Notebook tests passed!"
