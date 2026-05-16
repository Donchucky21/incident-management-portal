const express = require("express");
const cors = require("cors");
const client = require("prom-client");
const db = require("./db");
const { metricsMiddleware, metricsEndpoint } = require("./metrics");

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(metricsMiddleware);
app.use(express.json());

const register = new client.Registry();

client.collectDefaultMetrics({
  register,
});

const httpRequestDuration = new client.Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP requests in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.1, 0.3, 0.5, 1, 1.5, 2, 5],
});

const httpRequestCounter = new client.Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
});

register.registerMetric(httpRequestDuration);
register.registerMetric(httpRequestCounter);

app.use((req, res, next) => {
  const start = process.hrtime();

  res.on("finish", () => {
    const diff = process.hrtime(start);
    const duration = diff[0] + diff[1] / 1e9;

    const route = req.route ? req.route.path : req.path;

    httpRequestDuration
      .labels(req.method, route, res.statusCode)
      .observe(duration);

    httpRequestCounter
      .labels(req.method, route, res.statusCode)
      .inc();
  });

  next();
});

app.get("/", (req, res) => {
  res.json({
    message: "Incident Management API is running",
  });
});

app.get("/health", async (req, res) => {
  try {
    await db.query("SELECT 1");

    res.status(200).json({
      status: "ok",
      database: "connected",
      service: "incident-management-backend",
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      database: "disconnected",
      message: error.message,
    });
  }
});

app.get("/metrics", async (req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

app.get("/api/tickets", async (req, res) => {
  try {
    const result = await db.query(
      "SELECT * FROM tickets ORDER BY created_at DESC"
    );

    res.json(result.rows);
  } catch (error) {
    res.status(500).json({
      error: "Failed to fetch tickets",
      details: error.message,
    });
  }
});

app.post("/api/tickets", async (req, res) => {
  const { title, description, category, priority } = req.body;

  if (!title || !description || !category || !priority) {
    return res.status(400).json({
      error: "Title, description, category and priority are required",
    });
  }

  try {
    const result = await db.query(
      `INSERT INTO tickets (title, description, category, priority)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [title, description, category, priority]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    res.status(500).json({
      error: "Failed to create ticket",
      details: error.message,
    });
  }
});

app.patch("/api/tickets/:id/status", async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;

  if (!["Open", "In Progress", "Resolved"].includes(status)) {
    return res.status(400).json({
      error: "Status must be Open, In Progress, or Resolved",
    });
  }

  try {
    const result = await db.query(
      `UPDATE tickets
       SET status = $1, updated_at = CURRENT_TIMESTAMP
       WHERE id = $2
       RETURNING *`,
      [status, id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        error: "Ticket not found",
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    res.status(500).json({
      error: "Failed to update ticket",
      details: error.message,
    });
  }
});

app.get("/metrics", metricsEndpoint);

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend API running on port ${PORT}`);
});
