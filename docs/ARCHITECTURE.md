# CI/CD Architecture

## Pipeline boundaries

### Infrastructure

GitHub Actions -> AWS OIDC -> Terraform role -> S3 state -> AWS infrastructure.

Terraform owns:
- VPC
- EKS
- IAM
- ECR repository infrastructure
- RDS
- Redis
- KMS
- Secrets Manager infrastructure
- AWS-level observability

### Applications

GitHub Actions builds immutable service images and records image digests. Argo CD consumes GitOps manifests and deploys the selected digest to EKS.

### Observability workloads

Argo CD owns Prometheus, Grafana, Loki, Tempo, OpenTelemetry and Alertmanager workloads. Terraform owns AWS-level observability resources.

## Trust model

Fork PRs must not receive AWS credentials. Public/untrusted PRs run non-cloud validation only. Trusted PRs from the same repository may receive a read-only plan role where the repository policy permits it.

Environment-specific AWS roles are scoped through GitHub Environment OIDC subjects. GitHub recommends defining OIDC trust conditions and protecting deployment environments. citeturn0search1

## Deployment progression

1. PR validation
2. Terraform tests
3. Security scans
4. Terraform plan
5. Merge to main
6. Protected environment apply
7. Image build and security verification
8. Immutable digest promotion
9. GitOps update
10. Argo CD reconciliation
11. Observability/SLO verification

Terraform plans should be reviewed before apply; HashiCorp recommends using CI/CD and testing Terraform modules as part of pre-merge or deployment workflows. citeturn0search2turn0search3
