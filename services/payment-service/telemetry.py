import os
from opentelemetry import metrics, trace
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import OTLPMetricExporter
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

SERVICE_NAME = os.getenv("OTEL_SERVICE_NAME", os.getenv("SERVICE_NAME", "observastack-service"))
ENVIRONMENT = os.getenv("OTEL_RESOURCE_ATTRIBUTES", "deployment.environment.name=dev")
OTLP_ENDPOINT = os.getenv("OTEL_EXPORTER_OTLP_ENDPOINT", "http://opentelemetry-collector.observability.svc.cluster.local:4317")

resource = Resource.create({
    "service.name": SERVICE_NAME,
    "service.namespace": "observastack",
    "service.version": os.getenv("SERVICE_VERSION", "0.1.0"),
    "deployment.environment.name": os.getenv("ENVIRONMENT", "dev"),
})

# Traces
tracer_provider = TracerProvider(resource=resource)
tracer_provider.add_span_processor(
    BatchSpanProcessor(OTLPSpanExporter(endpoint=OTLP_ENDPOINT, insecure=True))
)
trace.set_tracer_provider(tracer_provider)
tracer = trace.get_tracer("observastack.application")

# Metrics
metric_reader = PeriodicExportingMetricReader(
    OTLPMetricExporter(endpoint=OTLP_ENDPOINT, insecure=True),
    export_interval_millis=int(os.getenv("OTEL_METRIC_EXPORT_INTERVAL", "10000")),
)
meter_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter("observastack.application")

request_counter = meter.create_counter(
    "http.server.request.count",
    description="Number of HTTP requests handled by the service",
)
request_duration = meter.create_histogram(
    "http.server.request.duration",
    unit="ms",
    description="HTTP request duration in milliseconds",
)

def record_request(method, route, status_code, duration_ms):
    attrs = {
        "http.request.method": method,
        "http.route": route,
        "http.response.status_code": status_code,
        "service.name": SERVICE_NAME,
    }
    request_counter.add(1, attrs)
    request_duration.record(duration_ms, attrs)
