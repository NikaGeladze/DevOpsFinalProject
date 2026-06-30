# Incident Response Runbook

## Severity Levels

| Level | Description | Response Time |
|-------|-------------|---------------|
| SEV-1 | App down or CRITICAL alert firing | Immediate (< 15 min) |
| SEV-2 | Elevated error rate (WARNING) | < 1 hour |
| SEV-3 | Degraded performance (latency) | < 4 hours |

## Detection

1. **Prometheus alerts** — http://localhost:9090/alerts
2. **Grafana alerting** — http://localhost:3000/alerting/list
3. **Health check log** — `logs/health.log` (from `scripts/health_check.sh`)
4. **CI/CD failure** — GitHub Actions workflow run

## Response Steps

### SEV-1: Demo App Down (`DemoAppDown`)

1. Confirm: `curl http://localhost:5000/health`
2. Check container: `docker compose ps demo-app`
3. Inspect logs: `docker compose logs demo-app --tail=50`
4. Restart: `docker compose restart demo-app`
5. If unresolved: `./scripts/rollback.sh` (local) or redeploy previous image

### SEV-1: High Error Rate (`HighErrorRate`)

1. Check recent deploys in GitHub Actions
2. Query errors in Grafana Loki: `{service="demo-app"} |= "ERROR"`
3. If caused by bad deploy → rollback (see `docs/rollback-procedure.md`)
4. If load-related → scale or investigate `/stress` endpoint abuse

### SEV-2: Elevated Error Rate (`ElevatedErrorRate`)

1. Monitor for escalation to CRITICAL
2. Review application logs and recent changes
3. Prepare rollback if trend continues

## Communication

- Document incident start/end time
- Record root cause and remediation in GitHub issue
- Update alert thresholds if false positive

## Post-Incident

1. Verify SLO impact (`docs/slo.md`)
2. Add regression test if applicable
3. Update this runbook if process gaps found
