#!/usr/bin/env bash
# Check Docker and Docker Compose availability
# Used before running Docker-based operations

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Check if docker is installed
if ! command -v docker >/dev/null 2>&1; then
  echo "✗ docker not found in PATH"
  echo "Install Docker: https://docs.docker.com/get-docker/"
  exit 2
fi

# Check if docker compose is available
if ! docker compose version >/dev/null 2>&1; then
  echo "✗ docker compose not available"
  echo "Ensure you have Docker Compose v2 installed"
  exit 2
fi

# Check if docker-compose.yml exists
COMPOSE_FILE="${1:-deploy/docker-compose.yml}"
if [ ! -f "$PROJECT_ROOT/$COMPOSE_FILE" ]; then
  echo "✗ $COMPOSE_FILE not found"
  exit 2
fi

echo "✓ Docker environment ready"
echo "  - Docker: $(docker --version)"
echo "  - Docker Compose: $(docker compose version)"
echo "  - Compose file: $COMPOSE_FILE"
