const client = require("prom-client");

// Collect default Node.js metrics: memory, CPU, event loop, garbage collection, etc.
client.collectDefaultMetrics({
  prefix: "incident_portal_",
});

// Counts total HTTP requests
const httpRequestsTotal = new client.Counter({
  name: "incident_http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "route", "status_code"],
});

// Measures request duration
const httpRequestDurationSeconds = new client.Histogram({
  name: "incident_http_request_duration_seconds",
  help: "HTTP request duration in seconds",
  labelNames: ["method", "route", "status_code"],
  buckets: [0.005, 0.01, 0.05, 0.1, 0.3, 0.5, 1, 2, 5],
});

// Middleware to track every request
function metricsMiddleware(req, res, next) {
  const start = Date.now();

  res.on("finish", () => {
    const duration = (Date.now() - start) / 1000;

    const route = req.route ? req.route.path : req.path;

    httpRequestsTotal.inc({
      method: req.method,
      route,
      status_code: res.statusCode,
    });

    httpRequestDurationSeconds.observe(
      {
        method: req.method,
        route,
        status_code: res.statusCode,
      },
      duration
    );
  });

  next();
}

// /metrics endpoint handler
async function metricsEndpoint(req, res) {
  res.set("Content-Type", client.register.contentType);
  res.end(await client.register.metrics());
}

module.exports = {
  metricsMiddleware,
  metricsEndpoint,
};
