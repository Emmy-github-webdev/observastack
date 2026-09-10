# 6.10 Observability Integration

## Environment root

Example:

```hcl
module "observability" {
  source = "../../modules/observability"

  project_name = "observastack"
  environment  = "staging"

  kms_key_arn       = module.kms.key_arn
  log_retention_days = 30

  create_alarms    = true
  create_dashboard = true
}
```

## Relationship to EKS

The EKS module creates the cluster control-plane logging configuration. This module provides additional application/platform/audit CloudWatch log groups and baseline AWS observability resources.

If the AWS CloudWatch Observability EKS add-on is selected later, its IAM/Pod Identity integration should be designed in the EKS/IAM layers rather than duplicating it here. AWS documents the add-on as a supported EKS integration with Pod Identity. 

## Relationship to RDS and Redis

RDS and Redis modules own their service-specific configuration and log delivery settings. This module provides shared AWS observability conventions, not ownership of those service resources.

## Relationship to GitOps

Argo CD owns Kubernetes observability workloads:

```text
Terraform
  └── AWS observability foundation
       ├── CloudWatch Log Groups
       ├── CloudWatch alarms
       └── CloudWatch dashboard

Argo CD
  └── Kubernetes observability
       ├── Prometheus
       ├── Grafana
       ├── Loki
       ├── Tempo
       ├── OpenTelemetry
       └── Alertmanager
```

This keeps the ownership boundary explicit.

## Least privilege

Use the output `log_group_arns` to create IAM policies for collectors or AWS integrations instead of granting wildcard access to all CloudWatch Logs resources.
