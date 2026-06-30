#!/usr/bin/env bash
# Single-command environment preparation (IaC)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "============================================"
echo "  DevOps Final Project — Environment Setup"
echo "============================================"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: '$1' is required but not installed."
    exit 1
  fi
}

require_cmd docker
if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE="docker-compose"
else
  echo "ERROR: Docker Compose is required."
  exit 1
fi

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

# shellcheck disable=SC1091
source .env

mkdir -p logs blue green screenshots

if command -v node >/dev/null 2>&1; then
  echo ""
  echo "=== Installing local Node.js dependencies ==="
  (cd app && npm install)
else
  echo "Node.js not found locally — skipping npm install (Docker build will still work)."
fi

echo ""
echo "=== Starting observability stack (Docker Compose) ==="
$COMPOSE up -d --build

echo ""
echo "=== Waiting for services to become healthy ==="
sleep 5
"$ROOT/scripts/validate-env.sh"

echo ""
echo "Setup complete."
echo "  App:         http://localhost:${APP_PORT:-5000}"
echo "  Grafana:     http://localhost:3000 (admin / ${GRAFANA_ADMIN_PASSWORD:-admin123})"
echo "  Prometheus:  http://localhost:9090"
echo "  Alertmanager:http://localhost:9093"
