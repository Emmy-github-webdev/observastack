import json
import logging
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

SERVICE = "payment-service"
PORT = int(os.getenv("PORT", "8080"))
ENVIRONMENT = os.getenv("ENVIRONMENT", "dev")

logging.basicConfig(level=os.getenv("LOG_LEVEL", "INFO"), format="%(message)s")
logger = logging.getLogger(SERVICE)

class Handler(BaseHTTPRequestHandler):
    def send_json(self, status, body):
        encoded = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def do_GET(self):
        if self.path == "/healthz":
            return self.send_json(200, {"status": "ok", "service": SERVICE})

        if self.path == "/readyz":
            return self.send_json(200, {"status": "ready", "service": SERVICE})

        if self.path == "/api/v1/payments":
            return self.send_json(200, {
                "service": SERVICE,
                "payments": [],
                "message": "Payment API foundation"
            })

        self.send_json(404, {"error": "not_found"})

    def log_message(self, fmt, *args):
        logger.info(json.dumps({
            "service": SERVICE,
            "environment": ENVIRONMENT,
            "method": self.command,
            "path": self.path,
        }))

if __name__ == "__main__":
    logger.info(json.dumps({"event": "service_started", "service": SERVICE, "port": PORT}))
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
