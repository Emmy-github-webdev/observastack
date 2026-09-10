# ObservaStack — Terraform Module 6.10: Observability

This module provisions the **AWS-managed observability foundation** for an ObservaStack environment.

## Scope

Terraform owns AWS-level observability resources:

- CloudWatch Log Groups
- Log retention
- KMS encryption for log groups when supplied
- Baseline CloudWatch alarms
- Optional CloudWatch infrastructure dashboard

Kubernetes-native observability remains GitOps-owned under:

```text
gitops/observability/
├── prometheus/
├── grafana/
├── loki/
├── tempo/
├── opentelemetry/
└── alertmanager/
```

Do **not** use this module to deploy Prometheus, Grafana, Loki, Tempo or OpenTelemetry workloads into EKS. That separation prevents Terraform and Argo CD from competing for Kubernetes ownership.

## Inputs

The module requires `project_name` and `environment`. A customer-managed KMS key may be supplied through `kms_key_arn`.

The environment root should normally choose retention according to policy:

| Environment | Suggested retention |
|---|---:|
| dev | 7 days |
| staging | 30 days |
| production | 90 days |

## Example

```hcl
module "observability" {
  source = "../../modules/observability"

  project_name = "observastack"
  environment  = "production"

  kms_key_arn       = module.kms.key_arn
  log_retention_days = 90

  create_alarms    = true
  create_dashboard = true

  tags = {
    CostCenter = "observastack-production"
  }
}
```

## Design boundary

This module does not create:

- Prometheus
- Grafana
- Loki
- Tempo
- OpenTelemetry Collector
- Alertmanager
- Kubernetes dashboards
- Kubernetes PrometheusRule resources
- SLO definitions

Those belong to the GitOps and `observability/` repository layers.

## Security

CloudWatch Log Groups can be encrypted with a customer-managed KMS key. Retention should be explicit rather than left indefinite. Alarm actions are supplied as ARNs rather than hard-coded into the module.

## Validation

```bash
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan
```
