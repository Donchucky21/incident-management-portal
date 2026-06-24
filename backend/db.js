const { Pool } = require("pg");

if (!process.env.DATABASE_URL) {
  throw new Error("DATABASE_URL environment variable is not set");
}

function cleanDatabaseUrl(databaseUrl) {
  const parsedUrl = new URL(databaseUrl);

  // Remove SSL query params that can override the pg ssl object
  parsedUrl.searchParams.delete("sslmode");
  parsedUrl.searchParams.delete("sslcert");
  parsedUrl.searchParams.delete("sslkey");
  parsedUrl.searchParams.delete("sslrootcert");

  return parsedUrl.toString();
}

const pool = new Pool({
  connectionString: cleanDatabaseUrl(process.env.DATABASE_URL),

  // Keep SSL encryption enabled, but disable certificate-chain verification
  // for this ECS/RDS portfolio deployment.
  ssl: {
    rejectUnauthorized: false,
  },

  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000,
});

pool.on("connect", () => {
  console.log("Connected to PostgreSQL database");
});

pool.on("error", (err) => {
  console.error("Unexpected PostgreSQL pool error:", err.message);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};
