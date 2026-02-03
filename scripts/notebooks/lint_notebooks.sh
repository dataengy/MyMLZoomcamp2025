#!/usr/bin/env bash
# Lint Jupyter notebooks with ruff via nbqa

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "==> Linting notebooks with nbqa ruff..."
uv run nbqa ruff check notebooks/ "$@"

echo "✓ Notebook linting complete!"
