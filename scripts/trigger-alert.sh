#!/usr/bin/env bash
# Flood /stress to trigger CRITICAL HighErrorRate alert (>5 errors/min)
set -euo pipefail

HOST="${1:-http://localhost:5000}"
RPS="${2:-20}"
BATCHES="${3:-6}"

echo "============================================"
echo "  TRIGGERING CRITICAL ALERT"
echo "  Target : $HOST"
echo "  Sending: $RPS errors x $BATCHES batches"
echo "============================================"

for i in $(seq 1 "$BATCHES"); do
  echo ""
  echo "Batch $i / $BATCHES ..."
  curl -sf "${HOST}/stress?count=${RPS}" | node -e "let d='';process.stdin.on('data',c=>d+=c);process.stdin.on('end',()=>{const j=JSON.parse(d);console.log('  Generated',j.errors_generated,'errors');});"
  sleep 10
done

echo ""
echo "Done. Verify alerts at:"
echo "  Prometheus: http://localhost:9090/alerts"
echo "  Grafana:    http://localhost:3000/alerting/list"
