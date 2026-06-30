#!/usr/bin/env bash
# Rollback: stop green staging instance, keep blue production active
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "Rolling back to Blue (production)..."

if [ -f "$ROOT/green.pid" ]; then
  PID="$(cat "$ROOT/green.pid")"
  if kill -0 "$PID" 2>/dev/null; then
    kill "$PID"
    echo "Stopped Green instance (PID $PID)."
  fi
  rm -f "$ROOT/green.pid"
  echo "Rollback complete. Blue remains active on port 3000."
else
  echo "No Green instance found — nothing to roll back."
fi

if [ -f "$ROOT/blue.pid" ]; then
  echo "Blue PID: $(cat "$ROOT/blue.pid") — http://localhost:3000/health"
else
  echo "WARNING: Blue is not running. Start with: ./scripts/deploy.sh blue"
fi
