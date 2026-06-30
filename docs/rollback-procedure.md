# Rollback Procedures

This project supports rollback at two levels: **local blue-green** and **cloud (Render)**.

## Local Blue-Green Rollback

Used when running `./scripts/deploy.sh blue` and `./scripts/deploy.sh green`.

### When to Rollback

- Green (staging on port 3001) shows errors after a new version deploy
- Health checks fail on the green instance

### Steps

```bash
./scripts/rollback.sh
```

This stops the Green instance and leaves Blue (port 3000) as production.

### Verify

```bash
curl http://localhost:3000/health
cat logs/health.log | tail -5
```

## Docker Rollback

Used when deploying with Docker Compose.

### Steps

1. Identify previous working image/commit:
   ```bash
   git log --oneline -5
   ```

2. Checkout previous version and rebuild:
   ```bash
   git checkout <previous-commit> -- app/
   docker compose up -d --build demo-app
   ```

3. Validate:
   ```bash
   ./scripts/validate-env.sh
   ```

4. Return to latest branch when ready:
   ```bash
   git checkout main
   ```

## Cloud Rollback (Render)

Used for production deployment via GitHub Actions → Render.

### Option A — Render Dashboard

1. Open [Render Dashboard](https://dashboard.render.com) → your service
2. Go to **Events** or **Deploys**
3. Click **Rollback** on the last known good deploy

### Option B — Git Revert + CI/CD

1. Revert the bad commit on `main`:
   ```bash
   git revert <bad-commit-sha>
   git push origin main
   ```
2. CI runs tests → security scans → triggers Render deploy hook
3. Post-deploy job verifies `PRODUCTION_URL`

### Option C — Manual Deploy Hook

Trigger a redeploy of a previous commit from Render dashboard, then verify:

```bash
PRODUCTION_URL=https://your-app.onrender.com ./scripts/post-deploy-check.sh
```

## Rollback Decision Matrix

| Environment | Method | Command / Action |
|-------------|--------|------------------|
| Local blue-green | Script | `./scripts/rollback.sh` |
| Docker Compose | Rebuild previous commit | `git checkout <sha> -- app/ && docker compose up -d --build` |
| Render (cloud) | Dashboard or git revert | Render rollback or `git revert` + push |
