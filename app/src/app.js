const express = require("express");
const path = require("path");
const client = require("prom-client");
const logger = require("./logger");

const app = express();
const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: "demo_app_" });

const REQUEST_COUNTER = new client.Counter({
  name: "app_requests_total",
  help: "Total number of requests received",
  labelNames: ["method", "endpoint", "status"],
  registers: [register],
});

const ERROR_COUNTER = new client.Counter({
  name: "app_errors_total",
  help: "Total number of errors",
  labelNames: ["endpoint"],
  registers: [register],
});

const REQUEST_LATENCY = new client.Histogram({
  name: "app_request_duration_seconds",
  help: "Request latency in seconds",
  labelNames: ["endpoint"],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5],
  registers: [register],
});

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

app.use((req, res, next) => {
  const start = process.hrtime.bigint();
  res.on("finish", () => {
    const durationSeconds = Number(process.hrtime.bigint() - start) / 1e9;
    const endpoint = req.route?.path || req.path;
    REQUEST_COUNTER.labels(req.method, endpoint, String(res.statusCode)).inc();
    REQUEST_LATENCY.labels(endpoint).observe(durationSeconds);
  });
  next();
});

app.get("/", (req, res) => {
  logger.info("Handling request on /");
  res.json({
    status: "ok",
    message: "DevOps Final Project demo app is running",
    version: process.env.APP_VERSION || "1.0.0",
  });
});

app.get("/user/:id", (req, res) => {
  logger.info("Fetched user profile", { userId: req.params.id });
  res.json({ userId: req.params.id, status: "active" });
});

app.post("/greet", (req, res) => {
  const name = req.body.name || "World";
  logger.info("Generated greeting", { name });
  res.json({ message: `Hello, ${name}!` });
});

app.get("/api/greet/:name", (req, res) => {
  const { name } = req.params;
  if (!name || name.trim().length === 0) {
    return res.status(400).json({ error: "Name is required" });
  }
  logger.info("API greeting generated", { name });
  res.json({ message: `Hello, ${name}! Deployed via CI/CD.` });
});

app.get("/error", (req, res) => {
  logger.error("Simulated error triggered on /error endpoint");
  ERROR_COUNTER.labels("/error").inc();
  res.status(500).json({ status: "error", message: "Simulated error" });
});

app.get("/stress", (req, res) => {
  const count = Math.min(parseInt(req.query.count || "10", 10), 100);
  for (let i = 0; i < count; i += 1) {
    logger.error(`Stress error #${i + 1} — simulating high error rate`);
    ERROR_COUNTER.labels("/stress").inc();
    REQUEST_COUNTER.labels("GET", "/stress", "500").inc();
  }
  res.json({ status: "stress", errors_generated: count });
});

app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    timestamp: new Date().toISOString(),
    version: process.env.APP_VERSION || "1.0.0",
  });
});

app.get("/api/health", (req, res) => {
  res.json({
    status: "OK",
    version: process.env.APP_VERSION || "1.0.0",
    timestamp: new Date().toISOString(),
  });
});

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

app.use(express.static(path.join(__dirname, "../public")));

app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

module.exports = app;
