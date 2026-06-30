#!/usr/bin/env bash
# Post-deployment smoke tests (CI or manual)
set -euo pipefail

URL="${PRODUCTION_URL:-${1:-http://localhost:5000}}"
URL="${URL%/}"

echo "=== Post-Deployment Verification ==="
echo "Target: $URL"

curl -sf "$URL/health" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const j=JSON.parse(d);if(!j.status)process.exit(1);console.log('Health:',j.status);});"

curl -sf "$URL/metrics" | grep -q "app_requests_total"
echo "Metrics endpoint OK"

curl -sf -X POST "$URL/greet" \
  -H "Content-Type: application/json" \
  -d '{"name":"CI"}' | grep -q "Hello, CI!"
echo "Greet endpoint OK"

echo "Post-deployment verification passed."
