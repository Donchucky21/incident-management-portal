const express = require("express");
const cors = require("cors");
const db = require("./db");
const { metricsMiddleware, metricsEndpoint } = require("./metrics");


async function initializeDatabase() {
  try {
    await db.query(`
      CREATE TABLE IF NOT EXISTS tickets (
        id SERIAL PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        description TEXT,
        category VARCHAR(100) DEFAULT 'General',
        priority VARCHAR(50) DEFAULT 'Medium',
        status VARCHAR(50) DEFAULT 'Open',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await db.query(`
      ALTER TABLE tickets
      ADD COLUMN IF NOT EXISTS category VARCHAR(100) DEFAULT 'General';
    `);

    console.log("Database initialized: tickets table is ready");
  } catch (error) {
    console.error("Database initialization failed:", error.message);
  }
}

initializeDatabase();

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(metricsMiddleware);
app.use(express.json());

app.get("/", (req, res) => {
  res.json({
    message: "Incident Management API is running",
  });
});

// App-only health check for ECS/ALB.
// This should not depend on the database, otherwise ECS may keep killing healthy app containers.
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "incident-management-backend",
  });
});

// Separate database health check.
// This uses the existing db module instead of an undefined pool variable.
app.get("/api/health/db", async (req, res) => {
  try {
    await db.query("SELECT 1");

    res.status(200).json({
      status: "ok",
      database: "connected",
    });
  } catch (error) {
    res.status(500).json({
      status: "error",
      database: "not connected",
      message: error.message,
    });
  }
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

// Prometheus metrics endpoint.
// Kept only one /metrics route to avoid route duplication.
app.get("/metrics", metricsEndpoint);

async function startServer() {
  await initializeDatabase();

  app.listen(PORT, "0.0.0.0", () => {
    console.log(`Backend API running on port ${PORT}`);
  });
}

startServer();