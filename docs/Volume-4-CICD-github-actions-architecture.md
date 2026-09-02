# ObservaStack — Enterprise Cloud Observability Platform

# CI/CD & GitHub Actions Architecture

**Document Version:** 1.0
**Status:** Architecture / Implementation Specification
**Platform:** GitHub Actions + AWS + ECR + EKS + Argo CD + Terraform
**Repository:** `observastack`
**Deployment Model:** Build Once → Promote → GitOps Deploy

---

# 1. Purpose

This document defines the complete CI/CD architecture for ObservaStack.

It establishes how code moves from developer changes through:

```text
Pull Request
    ↓
Validation
    ↓
Security
    ↓
Build
    ↓
Container Image
    ↓
Development
    ↓
Staging
    ↓
Production
```

The architecture covers:

* GitHub Actions
* Branching strategy
* Pull request validation
* Terraform CI/CD
* Terraform backend bootstrap
* AWS authentication
* GitHub OIDC
* ECR
* Container image builds
* Image signing/scanning
* Image promotion
* Environment promotion
* GitOps
* Argo CD
* Deployment approvals
* Secrets management
* Security gates
* Rollbacks
* Failure handling
* Workflow ownership
* Workflow dependencies
* Exact `.github/workflows/` structure

---

# 2. Core CI/CD Principles

ObservaStack follows these principles.

## 2.1 Build Once

A container image is built once for a release.

The image is not rebuilt for staging or production.

```text
Source
  ↓
Build
  ↓
Image
  ↓
Dev
  ↓
Staging
  ↓
Production
```

---

# 2.2 Promote, Don't Rebuild

The exact tested image is promoted between environments.

```text
Image Digest
    │
    ├── DEV
    │
    ├── STAGING
    │
    └── PRODUCTION
```

This guarantees that the artifact tested in staging is the artifact deployed to production.

---

# 2.3 Immutable Artifacts

Image digests are the source of truth.

Example:

```text
payment-service@sha256:abc123...
```

Tags are useful for human readability but must not be treated as the ultimate deployment identity.

---

# 2.4 GitOps Deployment

GitHub Actions does not directly deploy application workloads using `kubectl`.

Instead:

```text
GitHub Actions
      ↓
ECR
      ↓
GitOps Change
      ↓
Argo CD
      ↓
EKS
```

---

# 2.5 Terraform Owns Infrastructure

Terraform manages AWS infrastructure.

```text
Terraform
    ↓
AWS
    ├── VPC
    ├── EKS
    ├── ECR
    ├── RDS
    ├── Redis
    ├── IAM
    ├── KMS
    └── Supporting services
```

---

# 2.6 Short-Lived AWS Credentials

GitHub Actions must not store long-lived AWS access keys.

Authentication uses:

```text
GitHub Actions
       │
       │ OIDC
       ▼
AWS IAM Role
       │
       ▼
Temporary AWS Credentials
```

---

# 3. CI/CD High-Level Architecture

```text
                              GitHub
                                │
                 ┌──────────────┴──────────────┐
                 │                             │
              Pull Request                   Main
                 │                             │
                 ▼                             ▼
          ┌───────────────┐             Build Pipeline
          │ CI Validation │                   │
          ├───────────────┤                   ▼
          │ Tests         │              Security Gates
          │ Terraform     │                   │
          │ Lint          │                   ▼
          │ Security      │              Build Image
          │ GitOps        │                   │
          └───────────────┘                   ▼
                                          ECR / Dev
                                              │
                                              ▼
                                        DEV Deployment
                                              │
                                        Integration Tests
                                              │
                                              ▼
                                       STAGING Promotion
                                              │
                                        Acceptance Tests
                                              │
                                              ▼
                                       Approval Gate
                                              │
                                              ▼
                                      PRODUCTION Promotion
                                              │
                                              ▼
                                       Production EKS
                                              │
                                              ▼
                                      SLO / Health Checks
```

---

# 4. Environment Architecture

The deployment pipeline uses:

```text
DEV
 ↓
STAGING
 ↓
PRODUCTION
```

Each environment represents a progressively stronger validation stage.

---

# 5. Development Environment

Development is used for:

* Fast feedback
* Integration testing
* Application validation
* Observability validation
* Initial deployment testing
* Infrastructure experimentation

Deployment to development should be highly automated.

---

# 6. Staging Environment

Staging represents a production-like environment.

It is used for:

* Release validation
* End-to-end testing
* Acceptance testing
* Performance testing
* Observability validation
* Resilience testing
* Final pre-production verification

Staging should closely resemble production architecture.

---

# 7. Production Environment

Production is protected by additional controls.

Production deployment requires:

* Successful staging validation
* Security gates
* Required approval
* Immutable artifact promotion
* GitOps synchronization
* Post-deployment verification

---

# 8. AWS Account Strategy

The preferred enterprise model is:

```text
AWS Organization
│
├── Dev Account
│
├── Staging Account
│
└── Production Account
```

This provides strong environment isolation.

Each account can have its own:

* VPC
* EKS cluster
* ECR repositories
* RDS
* Redis
* IAM policies
* KMS keys
* Secrets Manager resources
* CloudWatch resources

---

# 9. ECR Strategy

Each environment/account has its own ECR repository set.

```text
Dev ECR
├── user-service
├── product-service
├── order-service
└── payment-service

Staging ECR
├── user-service
├── product-service
├── order-service
└── payment-service

Production ECR
├── user-service
├── product-service
├── order-service
└── payment-service
```

This provides production isolation.

---

# 10. Image Promotion

The image lifecycle is:

```text
Developer
   ↓
Git Commit
   ↓
CI
   ↓
Build Image
   ↓
Security Scan
   ↓
Push Dev ECR
   ↓
Deploy DEV
   ↓
Tests
   ↓
Promote Image
   ↓
Staging ECR
   ↓
Deploy STAGING
   ↓
Tests
   ↓
Approval
   ↓
Promote Image
   ↓
Production ECR
   ↓
Deploy PRODUCTION
```

---

# 11. Image Identity

Every build receives a unique immutable identifier.

Recommended metadata:

```text
Git SHA
Image Digest
Build Number
Repository
Service
Version
```

Example:

```text
Service:
payment-service

Git SHA:
a84c91e

Digest:
sha256:123456...
```

The digest is the authoritative deployment identifier.

---

# 12. Image Tagging

Recommended tags:

```text
payment-service:<git-sha>
payment-service:<version>
```

Environment tags may also be used:

```text
payment-service:dev
payment-service:staging
payment-service:production
```

However, environment tags are pointers.

The digest remains authoritative.

---

# 13. Image Promotion Model

Promotion should preserve the immutable image.

Conceptually:

```text
DEV ECR
   │
   │ same digest
   ▼
STAGING ECR
   │
   │ same digest
   ▼
PRODUCTION ECR
```

The pipeline must verify that:

```text
DEV_DIGEST == STAGING_DIGEST == PRODUCTION_DIGEST
```

for a promoted release.

---

# 14. Why Rebuilding Is Prohibited

Rebuilding an image in production introduces the possibility that:

```text
Staging Artifact ≠ Production Artifact
```

Reasons could include:

* Changed dependencies
* Base image changes
* Package repository changes
* Build environment changes
* Compiler differences
* Timestamp differences
* Supply-chain changes

Build-once promotion eliminates this class of drift.

---

# 15. Branching Strategy

The repository uses a protected mainline strategy.

Recommended:

```text
main
 │
 ├── feature/*
 ├── fix/*
 ├── chore/*
 └── security/*
```

Short-lived branches are preferred.

---

# 16. Pull Request Workflow

Changes flow through:

```text
feature/*
    ↓
Pull Request
    ↓
Automated Validation
    ↓
Code Review
    ↓
Merge
    ↓
main
```

Direct pushes to `main` are prohibited.

---

# 17. Pull Request Security Gates

Every relevant pull request should execute:

```text
Terraform validation
Application tests
Linting
Dependency scanning
Secret scanning
Container configuration checks
GitOps validation
Infrastructure security scanning
```

A failing required check blocks merging.

---

# 18. CODEOWNERS

Sensitive infrastructure should require review from appropriate owners.

Examples:

```text
terraform/       → Platform Engineering
security/        → Security / Platform
gitops/          → Platform Engineering
.github/         → Platform Engineering
```

The exact ownership mapping will be implemented in `.github/CODEOWNERS`.

---

# 19. GitHub Actions Architecture

The workflows are divided by responsibility.

```text
.github/
└── workflows/
    │
    ├── terraform-bootstrap.yml
    ├── terraform.yml
    ├── services-ci.yml
    ├── image-build.yml
    ├── image-promotion.yml
    ├── security.yml
    ├── gitops-validation.yml
    └── observability-validation.yml
```

---

# 20. Workflow Responsibility Matrix

| Workflow                       | Responsibility                                |
| ------------------------------ | --------------------------------------------- |
| `terraform-bootstrap.yml`      | Create/validate Terraform backend foundation  |
| `terraform.yml`                | Terraform plan/apply                          |
| `services-ci.yml`              | Application build/test                        |
| `image-build.yml`              | Build and publish container images            |
| `image-promotion.yml`          | Promote immutable images                      |
| `security.yml`                 | Security gates                                |
| `gitops-validation.yml`        | Validate GitOps configuration                 |
| `observability-validation.yml` | Validate dashboards/alerts/OTel configuration |

---

# 21. Terraform Bootstrap Workflow

The bootstrap workflow exists because the Terraform backend must exist before normal remote-state Terraform execution.

Workflow:

```text
GitHub
   ↓
AWS OIDC
   ↓
Bootstrap Role
   ↓
Terraform Backend
   ├── S3
   ├── Encryption
   ├── Versioning
   └── Locking
```

---

# 22. Bootstrap Requirements

The bootstrap process must be:

* Automated
* Idempotent
* Auditable
* Restricted
* Repeatable

The workflow should safely handle:

```text
Backend does not exist
```

and:

```text
Backend already exists
```

without destructive behavior.

---

# 23. Bootstrap Safety

The bootstrap workflow must not automatically destroy the backend.

Production backend resources should have deletion protection through policy and operational controls.

---

# 24. Terraform Workflow

Terraform workflow operates on pull requests and protected branches.

Pull request:

```text
terraform fmt
      ↓
terraform validate
      ↓
terraform lint
      ↓
security scan
      ↓
terraform plan
```

After merge:

```text
terraform plan
      ↓
approval
      ↓
terraform apply
```

---

# 25. Terraform Environment Execution

Terraform should execute separately for:

```text
dev
staging
production
```

Example logical jobs:

```text
terraform-plan-dev
terraform-apply-dev

terraform-plan-staging
terraform-apply-staging

terraform-plan-production
terraform-apply-production
```

---

# 26. Terraform Promotion

Infrastructure changes are not promoted through images.

Terraform changes are promoted through Git:

```text
Pull Request
    ↓
Review
    ↓
Merge
    ↓
Dev
    ↓
Staging
    ↓
Production
```

The exact Terraform workflow can use environment-specific approvals.

---

# 27. GitHub Environments

GitHub Environments should represent:

```text
dev
staging
production
```

Production should have:

* Required reviewers
* Restricted deployment branches
* Environment protection
* Auditability

---

# 28. AWS Authentication

The preferred authentication architecture is GitHub OIDC.

```text
GitHub Actions
      │
      │ OIDC Token
      ▼
AWS IAM OIDC Provider
      │
      ▼
IAM Role
      │
      ▼
Temporary Credentials
```

No permanent AWS credentials should be stored in GitHub.

---

# 29. IAM Role Separation

Separate GitHub deployment roles should be used where practical.

Example:

```text
GitHub OIDC
    │
    ├── Terraform Dev Role
    ├── Terraform Staging Role
    ├── Terraform Production Role
    │
    ├── Dev Release Role
    ├── Staging Release Role
    └── Production Release Role
```

Permissions must be scoped according to responsibility.

---

# 30. Production IAM

Production should have the strongest restrictions.

Production deployment permissions should not be available to arbitrary pull requests.

The production role should only be assumable by approved workflows and protected environments.

---

# 31. GitHub Secrets

Secrets should be minimized.

The preferred model is:

```text
GitHub
  │
  │ OIDC
  ▼
AWS IAM
  │
  ▼
AWS Secrets Manager
```

GitHub should not contain application runtime secrets.

---

# 32. Runtime Secrets

Application secrets belong in AWS Secrets Manager.

Kubernetes retrieves them through the External Secrets integration.

```text
AWS Secrets Manager
        │
        ▼
External Secrets
        │
        ▼
Kubernetes Secret
        │
        ▼
Application
```

---

# 33. CI Secrets

If a CI process genuinely requires a secret that cannot be obtained through AWS or OIDC, it must be stored as a GitHub secret or environment secret with the narrowest possible scope.

Secrets must never appear in:

* Source code
* Logs
* Terraform files
* Container images
* Git history

---

# 34. Application CI

`services-ci.yml` validates application code.

For each service:

```text
Checkout
   ↓
Dependency Installation
   ↓
Unit Tests
   ↓
Static Analysis
   ↓
Build
   ↓
Integration Tests
```

Services include:

```text
user-service
product-service
order-service
payment-service
```

---

# 35. Application Build

The application build should verify:

* Source compilation
* Unit tests
* Dependency integrity
* Static analysis
* Packaging
* Docker build readiness

The application must pass CI before an image is published.

---

# 36. Image Build Workflow

`image-build.yml` is responsible for container artifact creation.

Pipeline:

```text
Checkout
   ↓
Determine Service
   ↓
Build Docker Image
   ↓
Generate Metadata
   ↓
Container Scan
   ↓
Sign Image
   ↓
Push to Dev ECR
   ↓
Record Digest
```

---

# 37. Multi-Service Build Strategy

The workflow should support changed-service detection.

Example:

```text
Change:
services/payment-service/*
```

Only:

```text
payment-service
```

needs to be rebuilt.

If shared code changes affect multiple services, the workflow should rebuild the affected services.

---

# 38. Container Security

Images must be scanned before promotion.

Recommended controls:

```text
Trivy
SCA
Base Image Analysis
Secret Detection
SBOM Generation
```

Critical vulnerabilities should block promotion according to the project's vulnerability policy.

---

# 39. SBOM

The image pipeline should generate a Software Bill of Materials.

Conceptually:

```text
Source
  ↓
Build
  ↓
Image
  ↓
SBOM
  ↓
Security Scan
  ↓
Sign
  ↓
ECR
```

The SBOM should be associated with the build artifact.

---

# 40. Image Signing

Container images should be signed as part of the supply-chain security model.

The promotion workflow should verify:

* Image digest
* Signature
* Build provenance
* Scan status

before promotion.

---

# 41. Artifact Metadata

Every release should retain:

```text
Service
Git SHA
Image Digest
Build ID
SBOM
Scan Result
Signature
Build Timestamp
```

This creates release traceability.

---

# 42. Development Deployment

After a successful image build:

```text
Image
  ↓
Dev ECR
  ↓
GitOps update
  ↓
Argo CD
  ↓
Dev EKS
```

Argo CD performs the actual Kubernetes deployment.

---

# 43. GitOps Promotion

The desired state is represented in Git.

Conceptually:

```text
GitOps
│
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
```

The environment configuration references the promoted image digest.

---

# 44. GitOps Repository Update

The release workflow updates the appropriate GitOps configuration.

Example:

```text
dev
 └── payment-service
      └── image digest
```

After successful development testing:

```text
staging
 └── payment-service
      └── same image digest
```

After production approval:

```text
production
 └── payment-service
      └── same image digest
```

---

# 45. Argo CD

Argo CD is responsible for:

* Detecting Git changes
* Synchronizing Kubernetes state
* Managing application deployments
* Detecting drift
* Reporting synchronization status
* Supporting rollback

GitHub Actions should not bypass Argo CD.

---

# 46. Development Promotion

Development should be the most automated stage.

```text
Build
 ↓
Scan
 ↓
Push
 ↓
Update GitOps
 ↓
Argo CD
 ↓
Deploy
 ↓
Integration Tests
```

---

# 47. Staging Promotion

Staging requires successful development validation.

```text
DEV
 ↓
Integration Tests
 ↓
Promotion
 ↓
STAGING
 ↓
Acceptance Tests
```

The staging image must have the same digest as the development image.

---

# 48. Production Promotion

Production requires:

```text
Staging success
      ↓
Security verification
      ↓
Release approval
      ↓
Image promotion
      ↓
GitOps update
      ↓
Argo CD
      ↓
Production
```

---

# 49. Production Approval

Production deployment should use GitHub Environment protection.

Required reviewers may include:

* Platform owner
* Engineering owner
* Release owner

The exact number can be configured according to organizational policy.

---

# 50. Deployment Concurrency

Only one production deployment should normally execute at a time.

GitHub Actions concurrency controls should prevent competing production releases.

Example concept:

```text
production-deployment
    │
    ├── Release A → running
    │
    └── Release B → queued/cancelled
```

This prevents conflicting releases.

---

# 51. Deployment Verification

Every environment should perform health checks after deployment.

Checks may include:

```text
Pod readiness
Service availability
HTTP health endpoints
Error rate
Latency
Database connectivity
Redis connectivity
Telemetry ingestion
```

---

# 52. Production Verification

Production verification should additionally check:

* Error rate
* Request latency
* Saturation
* Availability
* SLO impact
* Kubernetes health
* Application health
* Dependency health

The observability platform becomes part of deployment verification.

---

# 53. Automated Rollback

A failed deployment should trigger controlled rollback behavior.

Conceptually:

```text
Production Deployment
        │
        ▼
Health Checks
        │
    ┌───┴───┐
    │       │
  PASS     FAIL
    │       │
    ▼       ▼
 Continue  Rollback
            │
            ▼
      Previous Digest
```

---

# 54. GitOps Rollback

Rollback should preferably be performed by reverting the GitOps desired state.

Example:

```text
Current:
sha256:new

Rollback:
sha256:previous
```

Argo CD then reconciles the previous version.

---

# 55. Emergency Rollback

An emergency release process may exist for critical incidents.

It must remain:

* Auditable
* Restricted
* Logged
* Traceable

Emergency access must not become the normal deployment mechanism.

---

# 56. Failed Promotion

If promotion fails:

```text
DEV
 ↓
Promotion Failure
 ↓
Stop
```

The pipeline must not automatically continue to staging or production.

---

# 57. Failed Staging

If staging validation fails:

```text
STAGING
   ↓
Test Failure
   ↓
STOP
   ↓
No Production Promotion
```

The release remains blocked until the issue is resolved.

---

# 58. Failed Production Deployment

If production health checks fail:

```text
Production
    ↓
Health Failure
    ↓
Rollback
    ↓
Previous Version
    ↓
Verification
```

The incident should be documented using the incident-report process defined elsewhere in the repository.

---

# 59. Security Pipeline

`security.yml` performs repository-wide security validation.

Potential checks:

```text
Secret scanning
Dependency scanning
SAST
IaC scanning
Container scanning
Kubernetes manifest scanning
SBOM validation
```

---

# 60. Infrastructure Security

Terraform should be checked for:

* Public exposure
* Weak IAM
* Unencrypted resources
* Open security groups
* Missing logging
* Missing backups
* Weak network controls
* Dangerous Terraform patterns

---

# 61. GitOps Security

GitOps validation should check:

* Valid YAML
* Valid Kubernetes manifests
* Helm configuration
* Kustomize configuration
* Image references
* Namespace boundaries
* Resource limits
* Security contexts
* Network policies

---

# 62. Observability Validation

`observability-validation.yml` validates:

```text
Dashboards
Alerts
Recording rules
SLO definitions
OpenTelemetry configuration
Prometheus configuration
Loki configuration
Tempo configuration
```

Invalid observability configuration must block the relevant deployment.

---

# 63. Workflow Permissions

GitHub Actions workflows must follow least privilege.

Workflows should explicitly declare permissions.

Example principle:

```text
contents: read
id-token: write
```

Only workflows that require write access should receive it.

---

# 64. Workflow Reusability

Common pipeline functionality should be implemented through reusable workflows or composite actions where appropriate.

Potential reusable components:

```text
Terraform validation
AWS authentication
Docker build
Security scanning
Image promotion
GitOps update
Deployment verification
```

This prevents duplication across services.

---

# 65. Workflow Structure

Final structure:

```text
.github/
│
├── workflows/
│   ├── terraform-bootstrap.yml
│   ├── terraform.yml
│   ├── services-ci.yml
│   ├── image-build.yml
│   ├── image-promotion.yml
│   ├── security.yml
│   ├── gitops-validation.yml
│   └── observability-validation.yml
│
├── CODEOWNERS
├── pull_request_template.md
│
└── ISSUE_TEMPLATE/
```

---

# 66. `terraform-bootstrap.yml`

Responsibilities:

```text
Authenticate to AWS
      ↓
Initialize bootstrap Terraform
      ↓
Validate configuration
      ↓
Plan backend
      ↓
Apply backend
```

Production backend changes require additional controls.

---

# 67. `terraform.yml`

Responsibilities:

```text
Detect Terraform changes
      ↓
Format
      ↓
Validate
      ↓
Lint
      ↓
Security Scan
      ↓
Plan
      ↓
Review
      ↓
Apply
```

The workflow must determine which environment is being targeted.

---

# 68. `services-ci.yml`

Responsibilities:

```text
Detect changed services
      ↓
Run service tests
      ↓
Static analysis
      ↓
Build
      ↓
Integration tests
```

No production deployment occurs from this workflow.

---

# 69. `image-build.yml`

Responsibilities:

```text
Build image
      ↓
Scan image
      ↓
Generate SBOM
      ↓
Sign
      ↓
Push to Dev ECR
      ↓
Record digest
```

---

# 70. `image-promotion.yml`

Responsibilities:

```text
Receive image digest
      ↓
Verify image
      ↓
Verify signature
      ↓
Verify scan
      ↓
Promote to Staging
      ↓
Run staging validation
      ↓
Approval
      ↓
Promote to Production
```

---

# 71. `security.yml`

Responsibilities:

```text
Repository security
Infrastructure security
Dependency security
Secret detection
Container security
```

---

# 72. `gitops-validation.yml`

Responsibilities:

```text
Validate manifests
Validate Helm
Validate Kustomize
Validate image references
Validate policies
```

---

# 73. `observability-validation.yml`

Responsibilities:

```text
Validate dashboards
Validate alerts
Validate recording rules
Validate SLO configuration
Validate OTel configuration
```

---

# 74. End-to-End Release Flow

The complete application release lifecycle is:

```text
Developer
    │
    ▼
Feature Branch
    │
    ▼
Pull Request
    │
    ├── Services CI
    ├── Terraform Validation
    ├── Security
    ├── GitOps Validation
    └── Observability Validation
    │
    ▼
Code Review
    │
    ▼
Merge to Main
    │
    ▼
Build
    │
    ▼
Scan
    │
    ▼
SBOM
    │
    ▼
Sign
    │
    ▼
Dev ECR
    │
    ▼
DEV GitOps
    │
    ▼
Argo CD
    │
    ▼
DEV EKS
    │
    ▼
Integration Tests
    │
    ▼
Promote Image
    │
    ▼
STAGING ECR
    │
    ▼
STAGING GitOps
    │
    ▼
Argo CD
    │
    ▼
STAGING EKS
    │
    ▼
Acceptance Tests
    │
    ▼
Production Approval
    │
    ▼
Promote Image
    │
    ▼
PRODUCTION ECR
    │
    ▼
Production GitOps
    │
    ▼
Argo CD
    │
    ▼
PRODUCTION EKS
    │
    ▼
SLO / Health Verification
```

---

# 75. Infrastructure Release Flow

Infrastructure follows a separate lifecycle:

```text
Terraform Change
      │
      ▼
Pull Request
      │
      ▼
Format
      │
      ▼
Validate
      │
      ▼
Lint
      │
      ▼
Security Scan
      │
      ▼
Plan
      │
      ▼
Review
      │
      ▼
Merge
      │
      ▼
DEV
      │
      ▼
STAGING
      │
      ▼
Production Approval
      │
      ▼
PRODUCTION
```

---

# 76. Application vs Infrastructure Pipelines

These pipelines remain logically separate.

```text
                 GitHub
                    │
          ┌─────────┴─────────┐
          │                   │
    Infrastructure         Application
          │                   │
      Terraform          Services CI
          │                   │
          ▼                   ▼
         AWS               ECR
          │                   │
          ▼                   ▼
         EKS              GitOps
                              │
                              ▼
                           Argo CD
```

---

# 77. Release Traceability

Every production deployment must be traceable to:

```text
Git commit
      ↓
Pull request
      ↓
CI run
      ↓
Build ID
      ↓
Image digest
      ↓
Security scan
      ↓
Promotion
      ↓
GitOps commit
      ↓
Argo CD deployment
```

This provides an auditable chain from source code to production.

---

# 78. Deployment Metadata

The deployment system should expose:

```text
service
version
git_sha
image_digest
environment
deployment_time
deployed_by
workflow_run
```

This metadata will later integrate with the ObservaStack observability dashboards.

---

# 79. Notifications

Important pipeline events should be observable.

Potential notifications:

* Deployment started
* Deployment succeeded
* Deployment failed
* Production approval requested
* Rollback triggered
* Security gate failed
* Terraform apply failed

Notification mechanisms can later integrate with the project's incident-management strategy.

---

# 80. Failure Isolation

A failure in one service should not unnecessarily block unrelated services.

For example:

```text
payment-service
   ↓
CI failure
```

should not automatically prevent:

```text
product-service
```

from being built unless there is a dependency relationship.

---

# 81. Deployment Ordering

Where application dependencies exist, deployment ordering must be explicit.

Example:

```text
Infrastructure
     ↓
Platform
     ↓
Database
     ↓
Shared dependencies
     ↓
User Service
     ↓
Product Service
     ↓
Order Service
     ↓
Payment Service
```

The actual application dependency graph will be defined during service implementation.

---

# 82. Database Migration Strategy

Database schema migrations must not be implicitly coupled to image deployment.

The eventual implementation should use a controlled migration mechanism.

Conceptually:

```text
Migration
    ↓
Validation
    ↓
Backup / Recovery Readiness
    ↓
Migration Execution
    ↓
Application Deployment
```

Backward-compatible migration patterns should be preferred.

---

# 83. Rollback Strategy

Application rollback:

```text
Current
  ↓
Previous image digest
  ↓
GitOps revert
  ↓
Argo CD
```

Infrastructure rollback:

```text
Terraform Change
  ↓
Assessment
  ↓
Corrective Terraform Change
```

Terraform should not be treated like an application version rollback mechanism.

---

# 84. Security Gate Philosophy

Security is not a final pipeline step.

Security checks occur throughout the lifecycle:

```text
PR
 │
 ├── Secret Scan
 ├── SAST
 ├── Dependency Scan
 ├── IaC Scan
 │
 ▼
Build
 │
 ├── Container Scan
 ├── SBOM
 └── Image Signing
 │
 ▼
Promotion
 │
 ├── Signature Verification
 └── Vulnerability Verification
 │
 ▼
Production
 │
 └── Policy / Approval
```

---

# 85. Supply Chain Security

The release pipeline should establish:

```text
Source Integrity
      ↓
Build Integrity
      ↓
Artifact Integrity
      ↓
Artifact Security
      ↓
Promotion Integrity
      ↓
Deployment Integrity
```

This forms the foundation for a software supply-chain security model.

---

# 86. Environment Protection Matrix

| Capability            |         Dev |        Staging | Production |
| --------------------- | ----------: | -------------: | ---------: |
| Automatic deployment  |         Yes | Yes/controlled |         No |
| Manual approval       |    Optional |       Optional |   Required |
| Protected environment | Recommended |            Yes |        Yes |
| Separate AWS account  | Recommended |            Yes |        Yes |
| Separate ECR          |         Yes |            Yes |        Yes |
| Image rebuild         |          No |             No |         No |
| Immutable digest      |         Yes |            Yes |        Yes |
| Security verification |         Yes |            Yes |        Yes |
| SLO verification      |       Basic |         Strong |     Strong |
| Rollback              |         Yes |            Yes |        Yes |

---

# 87. What GitHub Actions Must Never Do

The pipeline must not:

* Store permanent AWS access keys.
* Store production database passwords.
* Commit secrets.
* Build a different image for production.
* Deploy production with `kubectl` directly.
* Bypass Argo CD.
* Automatically destroy production infrastructure.
* Automatically approve its own production deployment.
* Skip security checks for normal releases.
* Mutate infrastructure outside Terraform.

---

# 88. What Argo CD Must Own

Argo CD owns:

```text
Kubernetes desired state
Application deployments
Observability workloads
Configuration reconciliation
Deployment drift
Rollback through Git state
```

---

# 89. What Terraform Must Own

Terraform owns:

```text
AWS infrastructure
Networking
EKS foundation
IAM
ECR
RDS
Redis/Valkey
KMS
Secrets infrastructure
AWS observability dependencies
```

---

# 90. What GitHub Actions Owns

GitHub Actions owns:

```text
CI
Testing
Security gates
Artifact creation
Artifact signing
Artifact promotion
Terraform orchestration
GitOps change automation
Release approvals
Deployment verification
```

---

# 91. Final CI/CD Architecture

```text
                             GITHUB
                                │
              ┌─────────────────┴──────────────────┐
              │                                    │
          Pull Request                            Main
              │                                    │
       ┌──────┴────────┐                     ┌─────┴──────┐
       │               │                     │            │
    CI Tests        Security              Build       Terraform
       │               │                     │            │
       └──────┬────────┘                     │            │
              │                              │            │
              ▼                              ▼            ▼
           Review                         Image        AWS Infra
              │                           Build            │
              ▼                              │             │
            Merge                            ▼             ▼
              │                           Dev ECR        EKS/VPC
              │                              │
              │                              ▼
              │                         DEV GitOps
              │                              │
              │                              ▼
              │                           Argo CD
              │                              │
              │                              ▼
              │                           DEV EKS
              │                              │
              │                         Integration
              │                            Tests
              │                              │
              │                              ▼
              │                         Image Promote
              │                              │
              │                              ▼
              │                        STAGING ECR
              │                              │
              │                              ▼
              │                        STAGING GitOps
              │                              │
              │                              ▼
              │                           Argo CD
              │                              │
              │                              ▼
              │                         STAGING EKS
              │                              │
              │                         Acceptance
              │                            Tests
              │                              │
              │                              ▼
              │                       Approval Gate
              │                              │
              │                              ▼
              │                       Production ECR
              │                              │
              │                              ▼
              │                       Production GitOps
              │                              │
              │                              ▼
              │                           Argo CD
              │                              │
              │                              ▼
              │                         Production EKS
              │                              │
              │                              ▼
              │                        SLO Verification
```

---

# 92. Final Decisions

The following decisions are considered part of the ObservaStack CI/CD architecture.

### Artifact strategy

**Build once, promote the same immutable image.**

### Image identity

**Image digest is authoritative.**

### ECR

**Separate ECR repositories per environment/account.**

### AWS authentication

**GitHub OIDC with short-lived IAM credentials.**

### Terraform state

**Automated backend bootstrap.**

### Application deployment

**GitOps through Argo CD.**

### Infrastructure deployment

**Terraform through GitHub Actions.**

### Production

**Protected GitHub Environment with approval.**

### Secrets

**AWS Secrets Manager + Kubernetes External Secrets integration.**

### Security

**Security gates throughout the SDLC.**

### Rollback

**GitOps-based immutable image rollback.**

### Production artifact

**Never rebuild the application image for production.**

---

# 93. Implementation Contract

The subsequent implementation must produce the following structure:

```text
.github/
│
├── workflows/
│   ├── terraform-bootstrap.yml
│   ├── terraform.yml
│   ├── services-ci.yml
│   ├── image-build.yml
│   ├── image-promotion.yml
│   ├── security.yml
│   ├── gitops-validation.yml
│   └── observability-validation.yml
│
├── CODEOWNERS
├── pull_request_template.md
│
└── ISSUE_TEMPLATE/
```

The workflows must implement the architecture defined in this document rather than merely serve as placeholder CI files.

---

# 94. Volume 5 Acceptance Criteria

Volume 5 is considered implemented when:

* [ ] GitHub Actions uses OIDC for AWS authentication.
* [ ] No long-lived AWS credentials are required.
* [ ] Terraform backend bootstrap is automated.
* [ ] Terraform PR validation exists.
* [ ] Terraform plans are generated automatically.
* [ ] Terraform production apply is protected.
* [ ] Application tests run automatically.
* [ ] Container images are built once.
* [ ] Images are scanned.
* [ ] SBOMs are generated.
* [ ] Images are signed.
* [ ] Images are pushed to Dev ECR.
* [ ] Images are promoted without rebuilding.
* [ ] Image digests are preserved across environments.
* [ ] Staging promotion requires successful Dev validation.
* [ ] Production promotion requires staging success.
* [ ] Production deployment requires approval.
* [ ] Argo CD owns Kubernetes deployment.
* [ ] GitHub Actions does not directly deploy application workloads.
* [ ] GitOps configuration is validated.
* [ ] Observability configuration is validated.
* [ ] Rollback is supported.
* [ ] Deployment concurrency is controlled.
* [ ] Production deployments are auditable.
* [ ] Security failures block promotion.
* [ ] The workflow structure matches the defined repository architecture.

---

# 95. Next Implementation Phase

The implementation should now proceed in this order:

```text
Phase 1
│
├── GitHub OIDC / AWS IAM design
│
├── GitHub Environments
│
└── Repository branch protections
│
▼
Phase 2
│
├── terraform-bootstrap.yml
│
├── terraform.yml
│
└── Terraform validation/security
│
▼
Phase 3
│
├── services-ci.yml
│
├── image-build.yml
│
└── Container security
│
▼
Phase 4
│
├── image-promotion.yml
│
├── Dev promotion
│
├── Staging promotion
│
└── Production approval
│
▼
Phase 5
│
├── GitOps integration
│
├── Argo CD synchronization
│
└── Deployment verification
│
▼
Phase 6
│
├── Rollback
│
├── Release traceability
│
└── End-to-end pipeline testing
```
