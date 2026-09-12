# CI/CD Security Model

## AWS authentication

GitHub Actions uses OIDC to obtain short-lived AWS credentials. Long-lived AWS access keys are not stored in GitHub.

## Roles

- Terraform bootstrap: backend infrastructure only
- Terraform plan: read-oriented plan permissions
- Terraform apply: environment infrastructure mutation
- Dev release: development ECR/application release permissions
- Staging release: staging promotion permissions
- Production release: production promotion permissions

## GitHub Environments

Use `dev`, `staging`, and `production`. Production should require reviewers and deployment branch/tag restrictions.

## Pull requests

Never grant AWS credentials to untrusted fork pull requests. The workflow therefore gates AWS-backed Terraform execution on repository ownership.

## Secrets

Do not place application secret values in Git. Secrets Manager metadata is Terraform-managed; secret values are injected/rotated outside Git where appropriate. Terraform state must be treated as sensitive.

## Destroy

Destroy is manual and requires an explicit `DESTROY` confirmation. Production additionally relies on GitHub Environment protection.
