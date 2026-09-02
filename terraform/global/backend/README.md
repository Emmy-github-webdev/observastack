# Terraform Backend

This module defines the durable S3 Terraform state backend.

The GitHub Actions bootstrap workflow is intentionally idempotent so the initial backend can be created automatically after GitHub OIDC is established.

The S3 backend uses native Terraform S3 state locking with:

```hcl
use_lockfile = true
```

DynamoDB-based Terraform state locking is not used.

The state bucket should have:

- Versioning
- Encryption
- Public access blocked
- Bucket-owner enforced ownership
- Secure transport enforced
- Restricted IAM access
