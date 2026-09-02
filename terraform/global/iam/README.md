# GitHub OIDC IAM Bootstrap

This configuration creates the AWS trust relationship used by GitHub Actions.

## Important bootstrap note

The first application of this configuration requires an already-authenticated AWS identity with permission to create:

- `aws_iam_openid_connect_provider`
- GitHub Actions IAM roles
- The associated IAM policies

That initial trust bootstrap is necessarily a one-time administrative operation. After it exists, GitHub Actions uses OIDC and short-lived credentials.

Set:

```text
github_org
github_repository
github_branch
aws_region
aws_account_id
```

Do not put AWS access keys in GitHub.

## Security

The trust policy is restricted to the configured repository and protected GitHub environments/branch.
