from pathlib import Path

SERVICES = {
    "user-service": "/api/v1/users",
    "product-service": "/api/v1/products",
    "order-service": "/api/v1/orders",
    "payment-service": "/api/v1/payments",
}

ROOT = Path(__file__).parents[1]

def test_all_services_exist():
    for service in SERVICES:
        service_dir = ROOT / "services" / service
        assert (service_dir / "app.py").exists()
        assert (service_dir / "Dockerfile").exists()
        assert (service_dir / "requirements.txt").exists()

def test_common_endpoints_present():
    for service in SERVICES:
        source = (ROOT / "services" / service / "app.py").read_text()
        assert '"/healthz"' in source
        assert '"/readyz"' in source

def test_api_contracts_present():
    for service, endpoint in SERVICES.items():
        source = (ROOT / "services" / service / "app.py").read_text()
        assert endpoint in source
