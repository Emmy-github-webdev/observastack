# Volume 6.15 Implementation Checklist

- [x] Terraform backend bootstrap workflow
- [x] Terraform plan/apply/destroy workflow
- [x] Manual destroy confirmation
- [x] GitHub Environment integration
- [x] AWS OIDC authentication
- [x] Fork PR AWS credential guard
- [x] Terraform fmt/validate/test gates
- [x] Security workflow
- [x] Service CI workflow
- [x] Immutable image build workflow
- [x] Digest-oriented promotion workflow
- [x] GitOps validation workflow
- [x] Observability validation workflow
- [x] CI/CD security model documentation
- [x] Release/rollback model documentation
- [x] Operations guidance

## Repository-specific follow-up before merge

1. Verify every role ARN exists and its IAM trust policy matches the repository's immutable OIDC subject claims.
2. Verify GitHub Environment protection rules.
3. Verify the shared ECR repository and global KMS key exist before image workflows run.
4. Align service Dockerfiles/build contexts with the actual service implementations.
5. Align GitOps promotion with the exact Argo CD application structure.
6. Run the workflows in a controlled branch before enabling production deployment.
