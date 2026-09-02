# GitHub Actions CI/CD

## Required repository/environment variables

Repository variables:

```text
AWS_REGION
AWS_ACCOUNT_ID
TERRAFORM_STATE_BUCKET
ECR_REGISTRY
```

Environment variables:

```text
TERRAFORM_BOOTSTRAP_ROLE_ARN
TERRAFORM_PLAN_ROLE_ARN
TERRAFORM_APPLY_ROLE_ARN
DEV_RELEASE_ROLE_ARN
STAGING_RELEASE_ROLE_ARN
PRODUCTION_RELEASE_ROLE_ARN
AWS_ACCOUNT_ID
```

For staging and production, also define the target account IDs as environment variables where the promotion workflow expects them.

## First-time bootstrap

1. Apply `terraform/global/iam` once using an administrative AWS identity.
2. Create the GitHub repository/environment variables from its outputs.
3. Run `terraform-bootstrap.yml`.
4. Confirm the S3 backend exists.
5. Normal Terraform workflows can now use OIDC and the remote backend.

No long-lived AWS credentials should be added to GitHub.

## Important

The repository/account names in CODEOWNERS and the IAM trust policy are placeholders until the real GitHub organization/repository is known.
