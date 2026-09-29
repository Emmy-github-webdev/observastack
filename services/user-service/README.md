# user-service

ObservaStack application service foundation.

## Endpoints

- `GET /healthz`
- `GET /readyz`
- `GET /api/v1/users`

## Configuration

- `PORT` — default `8080`
- `ENVIRONMENT` — default `dev`
- `LOG_LEVEL` — default `INFO`

OpenTelemetry instrumentation is intentionally introduced in the next observability phase.
