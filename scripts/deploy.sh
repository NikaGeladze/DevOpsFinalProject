#!/usr/bin/env bash
# Blue-Green deployment for local (non-Docker) instances
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-blue}"
PORT_BLUE=3000
PORT_GREEN=3001

cd "$ROOT/app"

if [ ! -d node_modules ]; then
  npm install
fi

echo "Deploying $VERSION environment..."

if [ "$VERSION" = "blue" ]; then
  if [ -f "$ROOT/blue.pid" ] && kill -0 "$(cat "$ROOT/blue.pid")" 2>/dev/null; then
    echo "Blue is already running on port $PORT_BLUE (PID $(cat "$ROOT/blue.pid"))"
    exit 0
  fi
  PORT=$PORT_BLUE APP_VERSION=blue node src/server.js &
  echo $! > "$ROOT/blue.pid"
  echo "Blue live on http://localhost:$PORT_BLUE"
elif [ "$VERSION" = "green" ]; then
  if [ -f "$ROOT/green.pid" ] && kill -0 "$(cat "$ROOT/green.pid")" 2>/dev/null; then
    echo "Green is already running on port $PORT_GREEN (PID $(cat "$ROOT/green.pid"))"
    exit 0
  fi
  PORT=$PORT_GREEN APP_VERSION=green node src/server.js &
  echo $! > "$ROOT/green.pid"
  echo "Green live on http://localhost:$PORT_GREEN"
else
  echo "Usage: $0 [blue|green]"
  exit 1
fi

sleep 2
curl -sf "http://localhost:$([ "$VERSION" = "blue" ] && echo $PORT_BLUE || echo $PORT_GREEN)/health" >/dev/null
echo "Health check passed for $VERSION."
