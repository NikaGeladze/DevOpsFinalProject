#!/usr/bin/env bash
# Post-setup environment validation
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ -f .env ]; then
  # shellcheck disable=SC1091
  source .env
fi

APP_PORT="${APP_PORT:-5000}"
APP_URL="http://localhost:${APP_PORT}"
FAIL=0
MAX_ATTEMPTS="${VALIDATE_RETRIES:-30}"
RETRY_INTERVAL="${VALIDATE_RETRY_INTERVAL:-2}"

check() {
  local name="$1"
  local url="$2"
  local expect="${3:-200}"
  local code="000"
  local attempt=1

  while [ "$attempt" -le "$MAX_ATTEMPTS" ]; do
    code="$(curl -s -o /dev/null -w '%{http_code}' "$url" || echo "000")"
    if [ "$code" = "$expect" ]; then
      if [ "$attempt" -eq 1 ]; then
        echo "  OK   $name ($url) — HTTP $code"
      else
        echo "  OK   $name ($url) — HTTP $code (ready after ${attempt} attempts)"
      fi
      return 0
    fi
    sleep "$RETRY_INTERVAL"
    attempt=$((attempt + 1))
  done

  echo "  FAIL $name ($url) — expected HTTP $expect, got $code after ${MAX_ATTEMPTS} attempts"
  FAIL=1
}

echo "=== Environment Validation ==="
check "Demo App /health" "$APP_URL/health"
check "Demo App /metrics" "$APP_URL/metrics"
check "Prometheus" "http://localhost:9090/-/ready"
check "Grafana" "http://localhost:3000/api/health"
check "Loki" "http://localhost:3100/ready"
check "Alertmanager" "http://localhost:9093/-/ready"

METRICS="$(curl -sf "$APP_URL/metrics" || true)"
if echo "$METRICS" | grep -q "app_requests_total"; then
  echo "  OK   Prometheus metrics exposed (app_requests_total)"
else
  echo "  FAIL Custom metrics not found on /metrics"
  FAIL=1
fi

if [ "$FAIL" -eq 0 ]; then
  echo "All validation checks passed."
  exit 0
fi

echo "One or more validation checks failed."
exit 1
