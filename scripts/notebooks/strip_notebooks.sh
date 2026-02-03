#!/usr/bin/env bash
# Strip outputs from all Jupyter notebooks

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "==> Stripping outputs from all notebooks..."

COUNT=0
while IFS= read -r -d '' notebook; do
  # Skip checkpoints
  if [[ "$notebook" == *".ipynb_checkpoints"* ]]; then
    continue
  fi

  echo "Stripping: $notebook"
  uv run nbstripout "$notebook"
  COUNT=$((COUNT + 1))
done < <(find notebooks -name "*.ipynb" -print0)

echo "✓ Stripped $COUNT notebooks!"
exit 0
