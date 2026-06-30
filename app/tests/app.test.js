const request = require("supertest");
const app = require("../src/app");

describe("DevOps Final Project App", () => {
  test("GET / returns ok status", async () => {
    const res = await request(app).get("/");
    expect(res.status).toBe(200);
    expect(res.body.status).toBe("ok");
  });

  test("GET /user/:id returns userId", async () => {
    const res = await request(app).get("/user/42");
    expect(res.body.userId).toBe("42");
    expect(res.body.status).toBe("active");
  });

  test("POST /greet returns greeting", async () => {
    const res = await request(app).post("/greet").send({ name: "Nick" });
    expect(res.body.message).toBe("Hello, Nick!");
  });

  test("GET /health returns ok", async () => {
    const res = await request(app).get("/health");
    expect(res.body.status).toBe("ok");
    expect(res.body.timestamp).toBeDefined();
  });

  test("GET /api/health returns OK", async () => {
    const res = await request(app).get("/api/health");
    expect(res.body.status).toBe("OK");
  });

  test("GET /metrics exposes Prometheus metrics", async () => {
    await request(app).get("/");
    const res = await request(app).get("/metrics");
    expect(res.status).toBe(200);
    expect(res.text).toContain("app_requests_total");
    expect(res.text).toContain("app_errors_total");
  });

  test("GET /error returns 500 and increments error metric", async () => {
    const res = await request(app).get("/error");
    expect(res.status).toBe(500);
    const metrics = await request(app).get("/metrics");
    expect(metrics.text).toContain('app_errors_total{endpoint="/error"}');
  });
});
