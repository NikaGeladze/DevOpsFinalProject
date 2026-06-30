# Screenshot Placeholders

Add the following screenshots before submission. Existing images from prior assignments are included where noted.

| Filename | What to capture | Status |
|----------|-----------------|--------|
| `ci-pipeline.png` | GitHub Actions — full workflow run (lint, security, deploy) | **NEEDED** |
| `security-scan.png` | GitHub Actions — Security Scanning job (Trivy, Gitleaks, npm audit) | **NEEDED** |
| `obs-dashboard.png` | Grafana dashboard with app metrics | Included (from observability-lab) |
| `jsonlogs.png` | Grafana Explore — Loki JSON logs | Included (from observability-lab) |
| `alert-rules.png` | Prometheus alerts after `./scripts/trigger-alert.sh` | Included (re-capture after fresh run recommended) |
| `RunningApp.png` | App UI at http://localhost:5000/index.html | Included (from midterm) |
| `blue.png` | Blue deployment on port 3000 | Included (from midterm) |
| `green.png` | Green deployment on port 3001 | Included (from midterm) |
| `rollback.png` | Terminal output of `./scripts/rollback.sh` | Included (from midterm) |
| `HealthCheck.png` | Contents of `logs/health.log` | Included (from midterm) |
| `render-deploy.png` | Render dashboard + successful deploy | **NEEDED** |
| `blocked-deploy.png` | CI failing and deploy skipped | **NEEDED** |
| `mergeRequest.png` | Pull request with passing CI | Included (from midterm) |
| `Actions.png` | GitHub Actions overview | Included (from midterm) |

Reference these in README.md using: `![description](screenshots/filename.png)`
