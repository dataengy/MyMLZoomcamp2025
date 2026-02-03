#!/usr/bin/env bash
# Check that notebooks have no outputs or execution counts

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "==> Checking notebooks are sanitized (no outputs)..."

FAILED=0
while IFS= read -r -d '' notebook; do
  # Skip checkpoints
  if [[ "$notebook" == *".ipynb_checkpoints"* ]]; then
    continue
  fi

  # Check if notebook has outputs or execution counts
  if uv run python -c "
import json
import sys

with open('$notebook') as f:
    nb = json.load(f)

has_output = any(
    c.get('outputs') or c.get('execution_count')
    for c in nb.get('cells', [])
)

sys.exit(1 if has_output else 0)
"; then
    echo "✓ $notebook"
  else
    echo "✗ $notebook has outputs - run: uv run nbstripout $notebook"
    FAILED=1
  fi
done < <(find notebooks -name "*.ipynb" -print0)

if [ $FAILED -eq 0 ]; then
  echo "✓ All notebooks are clean!"
  exit 0
else
  echo "✗ Some notebooks have outputs. Run: just strip-notebooks"
  exit 1
fi
