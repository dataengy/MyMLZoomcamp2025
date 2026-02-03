#!/usr/bin/env bash
# Format Jupyter notebooks with ruff via nbqa

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "==> Formatting notebooks with nbqa ruff format..."
uv run nbqa ruff notebooks/ format

echo "✓ Notebook formatting complete!"
