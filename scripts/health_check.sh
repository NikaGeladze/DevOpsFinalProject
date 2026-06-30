#!/usr/bin/env bash
# Periodic health monitoring — logs results to logs/health.log
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
URL="${HEALTH_CHECK_URL:-http://localhost:5000/health}"
LOG="$ROOT/logs/health.log"
INTERVAL="${HEALTH_CHECK_INTERVAL:-30}"

mkdir -p "$ROOT/logs"

echo "Health monitor started — checking $URL every ${INTERVAL}s"
echo "Logging to $LOG (Ctrl+C to stop)"

while true; do
  TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
  RESPONSE="$(curl -s -o /dev/null -w '%{http_code}' "$URL" || echo "000")"
  if [ "$RESPONSE" = "200" ]; then
    echo "[$TIMESTAMP] OK - App is healthy (HTTP $RESPONSE)" >> "$LOG"
  else
    echo "[$TIMESTAMP] FAIL - App unhealthy (HTTP $RESPONSE)" >> "$LOG"
  fi
  sleep "$INTERVAL"
done
