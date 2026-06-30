#!/usr/bin/env bash
# Docker-based blue-green: rebuild app image and restart demo-app container
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

TAG="${1:-latest}"
export APP_VERSION="$TAG"

if docker compose version >/dev/null 2>&1; then
  COMPOSE="docker compose"
else
  COMPOSE="docker-compose"
fi

echo "Building and deploying demo-app:$TAG ..."
$COMPOSE build demo-app
$COMPOSE up -d demo-app

sleep 5
"$ROOT/scripts/validate-env.sh"
echo "Docker deployment complete (version: $TAG)."
