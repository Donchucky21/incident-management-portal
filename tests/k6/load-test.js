import http from "k6/http";
import { sleep, check } from "k6";

export const options = {
  stages: [
    { duration: "30s", target: 10 },
    { duration: "1m", target: 30 },
    { duration: "30s", target: 0 },
  ],
  thresholds: {
    http_req_failed: ["rate<0.05"],
    http_req_duration: ["p(95)<1000"],
  },
};

export default function () {
  const response = http.get("http://backend:5000/api/tickets");

  check(response, {
    "status is 200": (r) => r.status === 200,
    "response time below 1s": (r) => r.timings.duration < 1000,
  });

  sleep(1);
}
