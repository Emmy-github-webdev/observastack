# CI/CD Operations

## Common checks

```bash
terraform fmt -check -recursive terraform
terraform test ./terraform/tests/terraform/modules/...
```

For an environment:

```bash
cd terraform/environments/dev
terraform init
terraform validate
terraform plan
```

## Exit code handling

Do not use `terraform plan -detailed-exitcode` unless the workflow explicitly handles exit code `2` as "changes present". Standard `terraform plan` is used by this package to avoid treating an expected plan as a failed job.

## State locking

Environment roots use the S3 backend with lockfile locking. The global backend root is intentionally local-state because it creates the backend infrastructure itself.
