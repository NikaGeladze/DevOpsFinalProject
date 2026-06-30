# Service Level Objectives (SLO)

## Availability

| Service | SLO Target | Measurement |
|---------|------------|-------------|
| demo-app | 99.5% monthly uptime | `up{job="demo-app"}` in Prometheus |
| Health endpoint | 99.9% success rate | HTTP 200 on `/health` |

**Error budget:** 0.5% downtime ≈ 3.6 hours/month.

## Latency

| Metric | SLO Target |
|--------|------------|
| p95 request latency | < 500 ms under normal load |
| p99 request latency | < 1 s under normal load |

Prometheus alert `HighRequestLatency` fires when p95 exceeds 1 s for 2 minutes.

## Error Rate

| Metric | SLO Target |
|--------|------------|
| Application errors | < 5 errors/min sustained |

Prometheus alert `HighErrorRate` (CRITICAL) fires above 5 errors/min.

## Monitoring Windows

- **Metrics retention:** 15 days (Prometheus TSDB)
- **Log retention:** 7 days (Loki local config)
- **Health check interval:** 30 seconds (`scripts/health_check.sh`)

## Review Cadence

- Weekly: review Grafana dashboards and alert noise
- Monthly: evaluate SLO compliance and adjust thresholds
