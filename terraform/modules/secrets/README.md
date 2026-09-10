# ObservaStack 6.9 — Secrets Manager Module

This module provisions the **AWS Secrets Manager metadata layer** for ObservaStack environments.

## Design goals

- Customer-managed KMS encryption.
- Environment-scoped secret names.
- Recovery windows instead of immediate deletion by default.
- Optional Secrets Manager resource policies with public-policy blocking.
- No plaintext secret values in Terraform configuration or state.
- Compatible with the ObservaStack External Secrets / EKS Pod Identity design.
- RDS master credentials are consumed from the RDS-managed secret instead of duplicated.
- Redis authentication secrets can be consumed from an existing secret instead of duplicated.

AWS Secrets Manager supports a customer-managed KMS key through `kms_key_id` and supports a configurable recovery window of 0 or 7–30 days. citeturn0search0turn0search14

## Important state-security decision

This module deliberately **does not create `aws_secretsmanager_secret_version` resources** and does not accept plaintext passwords, tokens, API keys, or certificates.

Terraform can manage secret metadata safely, but a secret value supplied through Terraform becomes part of Terraform state. Populate values through a controlled runtime/bootstrap process instead, then let workloads retrieve them from Secrets Manager.

For example, use an approved administrative/bootstrap process to call Secrets Manager after the infrastructure exists. Do not commit the value to Git.

## Directory

```text
terraform/modules/secrets/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── locals.tf
└── README.md
```

## Example

```hcl
module "secrets" {
  source = "../../modules/secrets"

  project_name = "observastack"
  environment  = "dev"
  kms_key_arn  = module.kms.key_arn

  recovery_window_in_days = 7

  secrets = {
    "applications/user-service" = {
      description = "User service application credentials"
    }

    "applications/payment-service" = {
      description = "Payment service credentials"
    }

    "integrations/stripe" = {
      description = "Stripe integration credentials"
    }
  }

  rds_master_user_secret_arn = module.rds.master_user_secret_arn
  redis_auth_secret_arn      = module.redis.auth_secret_arn
}
```

## Naming

Given:

```text
project_name = observastack
environment  = staging
secret key   = applications/payment-service
```

The resulting secret name is:

```text
observastack/staging/applications/payment-service
```

## RDS integration

The RDS module already uses `manage_master_user_password = true`, so Amazon RDS owns the master credential secret. This module should receive the RDS secret ARN as an input/reference only.

Do **not** create a second copy of the RDS master password in Secrets Manager.

## Redis integration

If Redis AUTH is enabled and a separate Secrets Manager secret is used, pass its ARN through `redis_auth_secret_arn`. This module does not copy or expose the credential.

The Redis module's own AUTH token should be handled carefully because provider-managed authentication material can still be represented in Terraform state. Prefer a controlled secret/bootstrap workflow for production credentials.

## EKS consumption

The intended flow is:

```text
AWS Secrets Manager
        │
        ▼
External Secrets / Secrets Store integration
        │
        ▼
EKS Pod Identity
        │
        ▼
Kubernetes workload
```

AWS documents both the AWS Secrets and Configuration Provider for the Kubernetes Secrets Store CSI Driver and Pod Identity as supported ways to consume Secrets Manager values from EKS. citeturn0search5turn0search6

The Kubernetes/External Secrets implementation belongs in the platform/GitOps layers, not inside this AWS Terraform module.

## Rotation

Rotation is an operational capability, not something this module silently enables for every secret. Database credentials, API keys, certificates, and application tokens can have different rotation mechanisms.

When a secret needs managed rotation, add an explicit rotation implementation using `aws_secretsmanager_secret_rotation` and the appropriate rotation Lambda/service. Keep that configuration separate from this base metadata module.

## Resource policies

Use `secret_resource_policies` only when IAM identity policies are insufficient, such as a deliberate cross-account access pattern. Keep policies narrowly scoped to exact principals and actions.

`block_public_policy = true` is enabled by default.

## Environment guidance

Recommended recovery windows:

| Environment | Recovery window |
|---|---:|
| dev | 7 days |
| staging | 14 days |
| production | 30 days |

Production should not use `0` unless there is a documented, approved reason for immediate deletion.

## Security rules

1. Never commit secret values.
2. Never place secret values in `.tfvars` files.
3. Never output secret values from Terraform.
4. Treat Terraform state as sensitive infrastructure data.
5. Use customer-managed KMS keys where the architecture requires explicit key control.
6. Grant External Secrets only `DescribeSecret` and `GetSecretValue` for the exact secret ARNs it needs.
7. Do not grant workloads `secretsmanager:ListSecrets` unless genuinely required.
8. Keep secret names and tags free of sensitive values. AWS notes that tags are not encrypted. citeturn0search14
9. Use environment-specific secrets; do not share application credentials across dev/staging/production.
10. Deploy applications using references to secrets, not baked-in credentials.

## Validation

Run from the module directory:

```bash
terraform fmt -check -recursive
terraform init
terraform validate
```

Then validate an environment root with:

```bash
terraform plan
```

## Relationship to ObservaStack modules

```text
6.3 KMS
   │
   ▼
6.7 RDS ───────────────► RDS-managed master secret
   │
6.8 Redis ─────────────► Redis authentication secret/reference
   │
   ▼
6.9 Secrets Manager ───► application/integration secret metadata
   │
   ▼
6.4 IAM / EKS Pod Identity
   │
   ▼
GitOps / External Secrets
   │
   ▼
Microservices
```
