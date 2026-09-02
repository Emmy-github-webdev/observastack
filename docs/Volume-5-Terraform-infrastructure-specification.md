# ObservaStack — Enterprise Cloud Observability Platform

## Terraform Infrastructure Specification

**Document Version:** 1.0
**Status:** Architecture / Implementation Specification
**Infrastructure Platform:** Amazon Web Services (AWS)
**Infrastructure as Code:** Terraform
**Primary Workload Platform:** Amazon EKS
**Environment Model:** Development / Staging / Production

---

# 1. Purpose

This document defines the complete Terraform infrastructure architecture for **ObservaStack**, an enterprise-grade cloud observability platform running on AWS.

Terraform is responsible for provisioning and managing the AWS infrastructure and platform foundations required by the application and observability layers.

The objective is to create infrastructure that is:

* Repeatable
* Secure
* Highly available
* Multi-AZ
* Environment-aware
* Modular
* Auditable
* Version controlled
* Disaster-recoverable
* Cost conscious
* Suitable for CI/CD automation
* Suitable for GitOps integration

Terraform is deliberately limited to infrastructure responsibilities.

Kubernetes workloads are deployed and reconciled through **Argo CD**, not directly managed as application workloads by Terraform.

---

# 2. Terraform Responsibility Model

ObservaStack separates infrastructure provisioning from workload deployment.

```text
                    Git Repository
                         │
             ┌───────────┴───────────┐
             │                       │
        Terraform                 GitOps
             │                       │
             ▼                       ▼
      AWS Infrastructure        Kubernetes Workloads
             │                       │
     ┌───────┼────────┐       ┌──────┼─────────────┐
     │       │        │       │      │      │       │
    VPC     EKS      RDS     Apps  Metrics Logs  Traces
     │       │        │       │      │      │       │
    IAM     ECR     Redis   ArgoCD Prom  Loki    Tempo
    KMS    Secrets           Grafana OTel Alertmanager
```

## Terraform owns

* AWS networking
* VPC
* Subnets
* Route tables
* Internet Gateway
* NAT Gateways
* VPC endpoints
* Security groups
* EKS cluster
* EKS node groups
* EKS encryption
* IAM roles
* IAM policies
* IRSA/OIDC integration
* ECR repositories
* RDS PostgreSQL
* ElastiCache Redis/Valkey infrastructure
* KMS keys
* Secrets Manager infrastructure
* AWS observability integrations
* CloudWatch resources
* SNS/EventBridge infrastructure where required
* Environment infrastructure

## Terraform does not own

* Application deployments
* Kubernetes application releases
* Prometheus application configuration
* Grafana dashboards deployed through GitOps
* Loki workload deployment
* Tempo workload deployment
* OpenTelemetry Collector workload deployment
* Alertmanager workload deployment
* Application configuration releases

These are managed through Kubernetes manifests/Helm and Argo CD.

---

# 3. Infrastructure Design Principles

The Terraform implementation must follow these principles.

## 3.1 Infrastructure as Code

All persistent infrastructure must be defined as code.

Manual creation of production infrastructure is prohibited except for explicitly documented break-glass operations.

---

## 3.2 Immutable Infrastructure

Infrastructure changes should be made through Terraform plans and reviewed changes.

Avoid manual modification of Terraform-managed resources.

---

## 3.3 Least Privilege

IAM permissions must be limited to the minimum permissions required by each workload.

Examples:

* EKS node roles should not receive broad administrative permissions.
* Application service accounts should receive only required AWS permissions.
* Observability components should receive only required telemetry permissions.
* Terraform CI/CD roles should use controlled deployment permissions.

---

## 3.4 Environment Isolation

Development, staging and production must be independently deployable.

Each environment has its own Terraform root configuration and state.

Terraform workspaces are not used as the primary mechanism for environment isolation.

---

## 3.5 Multi-AZ Availability

Production infrastructure must be distributed across multiple Availability Zones.

The architecture should support:

```text
                    AWS Region
                        │
          ┌─────────────┼─────────────┐
          │             │             │
         AZ-A          AZ-B          AZ-C
          │             │             │
      Public/Subnet Public/Subnet Public/Subnet
      Private/Subnet Private/Subnet Private/Subnet
      Data/Subnet    Data/Subnet    Data/Subnet
```

Development and staging may use fewer Availability Zones where cost optimization is appropriate.

---

## 3.6 Private-by-Default

Sensitive workloads should not be directly exposed to the Internet.

Examples:

* EKS worker nodes → private subnets
* RDS → isolated/data subnets
* Redis/Valkey → isolated/data subnets
* Internal platform services → private networking

Public subnets are primarily intended for Internet-facing load-balancing and controlled egress infrastructure.

---

## 3.7 Encryption by Default

Encryption must be enabled for:

* EKS secrets
* RDS storage
* Redis/Valkey
* ECR where applicable
* Secrets Manager
* CloudWatch logs where configured
* S3 Terraform state
* Other supported persistent data

AWS KMS customer-managed keys should be used where stronger key ownership and lifecycle control are required.

---

# 4. AWS Environment Architecture

ObservaStack uses three logical environments:

```text
AWS
│
├── Development
│
├── Staging
│
└── Production
```

Each environment has its own:

* VPC
* EKS cluster
* Node groups
* ECR integration
* RDS database
* Redis/Valkey infrastructure
* IAM integrations
* KMS integrations
* Secrets infrastructure
* Observability infrastructure

Production receives the strongest availability, security, backup and operational configuration.

---

# 5. Terraform Repository Architecture

The Terraform directory is:

```text
terraform/
│
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── redis/
│   ├── ecr/
│   ├── iam/
│   ├── kms/
│   ├── secrets/
│   └── observability/
│
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
│
└── global/
    ├── backend/
    └── iam/
```

---

# 6. Terraform Module Architecture

Each module must have a clearly defined responsibility.

```text
modules/
│
├── vpc
│   └── Networking
│
├── eks
│   └── Kubernetes control plane and node infrastructure
│
├── rds
│   └── PostgreSQL
│
├── redis
│   └── Redis/Valkey
│
├── ecr
│   └── Container image repositories
│
├── iam
│   └── IAM roles and workload permissions
│
├── kms
│   └── Encryption keys
│
├── secrets
│   └── Secrets Manager infrastructure
│
└── observability
    └── AWS observability integrations
```

Modules should remain reusable and should not contain environment-specific hardcoding.

---

# 7. Module Contract

Every Terraform module should follow the same basic structure:

```text
module-name/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── locals.tf
├── data.tf
└── README.md
```

Additional files may be introduced where complexity requires them.

For example:

```text
tests/
```

may be added to modules that require dedicated Terraform tests.

---

# 8. Provider Strategy

Terraform must explicitly declare:

* Terraform version requirements
* AWS provider version constraints
* Kubernetes provider requirements where required
* Helm provider requirements where required
* Provider aliases where multi-region or multi-account operations are introduced

The Terraform dependency lock file must be committed to version control.

Provider versions must not be left completely unconstrained.

---

# 9. AWS Provider Configuration

Each environment defines its AWS provider configuration.

Conceptually:

```text
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
```

The exact region is environment-configurable.

No production-critical module should hardcode an AWS region.

---

# 10. Resource Tagging Strategy

All supported AWS resources must use consistent tags.

Minimum tagging model:

```text
Project
Environment
ManagedBy
Owner
CostCenter
Component
Repository
```

Example:

```text
Project     = "ObservaStack"
Environment = "production"
ManagedBy   = "Terraform"
Owner       = "Platform Engineering"
CostCenter  = "ObservaStack"
Component   = "EKS"
```

Tags must be inherited through provider-level default tags wherever possible.

---

# 11. Terraform State Architecture

Terraform state is treated as a critical infrastructure asset.

State must not be stored locally for shared environments.

The architecture uses remote state.

```text
Terraform
    │
    ▼
S3 Backend
    │
    ├── Encryption
    ├── Versioning
    └── State protection
```

State locking must be enabled using the supported locking mechanism of the selected Terraform/S3 backend implementation.

---

# 12. State Isolation

State must be isolated by environment.

Conceptually:

```text
S3 State
│
├── dev/
│   └── observastack.tfstate
│
├── staging/
│   └── observastack.tfstate
│
└── production/
    └── observastack.tfstate
```

Production state must never share the same state file with development.

---

# 13. State Security

Terraform state may contain sensitive infrastructure metadata.

Therefore:

* S3 state must be encrypted.
* Bucket versioning must be enabled.
* Bucket access must be restricted.
* Public access must be blocked.
* IAM access must be least privilege.
* State access must be auditable.
* CI/CD should use dedicated deployment roles.

Terraform state must never be committed to Git.

---

# 14. Global Infrastructure

The `terraform/global/` directory contains infrastructure that must exist before individual environments can be provisioned.

```text
global/
├── backend/
└── iam/
```

## Backend

Responsible for:

* Terraform state bucket
* State encryption
* Versioning
* State access controls
* Locking configuration

## Global IAM

Responsible for shared deployment identities where required.

Examples:

* Terraform CI role
* Infrastructure deployment role
* Read-only audit role

---

# 15. VPC Architecture

The VPC module is the foundation of each environment.

Production network:

```text
                         Internet
                            │
                     Internet Gateway
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
      AZ-A                AZ-B                AZ-C
        │                   │                   │
  ┌─────┼─────┐       ┌─────┼─────┐       ┌─────┼─────┐
  │     │     │       │     │     │       │     │     │
Public Private Data   Public Private Data   Public Private Data
  │      │     │       │      │     │       │      │     │
 ALB    EKS   RDS     ALB    EKS   RDS     ALB    EKS   RDS
       Nodes  Redis         Nodes  Redis         Nodes  Redis
```

---

# 16. VPC Subnet Model

Three logical subnet classes are required for production.

## Public subnets

Used for:

* Internet-facing load balancers
* NAT Gateways
* Other explicitly public infrastructure

## Private subnets

Used for:

* EKS worker nodes
* Internal services
* Application workloads

## Data/isolated subnets

Used for:

* RDS PostgreSQL
* Redis/Valkey
* Other data services

The data layer should not have direct Internet access.

---

# 17. NAT Gateway Architecture

Production uses NAT Gateway infrastructure distributed across Availability Zones.

Preferred architecture:

```text
Private AZ-A ──> NAT AZ-A
Private AZ-B ──> NAT AZ-B
Private AZ-C ──> NAT AZ-C
```

This prevents a single NAT Gateway from becoming a cross-AZ dependency and improves resilience.

Development may use a reduced NAT configuration when cost optimization is prioritized.

---

# 18. VPC Endpoints

VPC endpoints should be used where appropriate to reduce unnecessary Internet/NAT traffic and improve private connectivity.

Candidate services include:

* S3
* ECR API
* ECR DKR
* CloudWatch
* STS
* Secrets Manager
* SSM

Endpoint selection should balance:

* Security
* Availability
* Operational simplicity
* Cost

---

# 19. Security Groups

Security groups must follow service-to-service communication requirements.

Conceptually:

```text
Internet
   │
   ▼
Public ALB
   │
   ▼
EKS Workloads
   │
   ├──────► RDS PostgreSQL
   │
   └──────► Redis/Valkey
```

Only required ports should be allowed.

Example:

```text
ALB → Application
Application → PostgreSQL
Application → Redis
```

Direct Internet access to PostgreSQL and Redis is prohibited.

---

# 20. EKS Architecture

The EKS module provisions the Kubernetes platform foundation.

```text
                    EKS Cluster
                         │
             ┌───────────┴───────────┐
             │                       │
       Control Plane             Data Plane
             │                       │
       AWS Managed              Managed Node
       Kubernetes               Groups
                                     │
                         ┌───────────┼───────────┐
                         │           │           │
                       AZ-A        AZ-B        AZ-C
                         │           │           │
                       Nodes       Nodes       Nodes
```

---

# 21. EKS Control Plane

The cluster must support:

* Kubernetes version management
* Private networking
* Encryption
* IAM integration
* CloudWatch logging where required
* OIDC integration
* Multi-AZ control plane
* Cluster security configuration

The Kubernetes API endpoint should be private-first.

Public API access, if enabled, must be explicitly restricted.

---

# 22. EKS Cluster Encryption

Kubernetes secrets stored in the EKS control plane must be encrypted using AWS KMS.

The EKS module consumes the KMS key provided by the KMS module.

```text
EKS
 │
 └── KMS
      └── Cluster Secret Encryption
```

---

# 23. EKS Node Groups

Managed node groups are the default compute model.

Node groups should be separated by workload characteristics where required.

Potential groups include:

```text
system
application
observability
```

System workloads include components such as:

* CoreDNS
* kube-proxy
* AWS networking components

Application nodes run business services.

Observability nodes may be isolated where resource requirements justify dedicated capacity.

---

# 24. EKS Node Security

Worker nodes must:

* Run in private subnets.
* Use dedicated IAM roles.
* Use approved AMIs.
* Receive security updates.
* Use security groups with controlled ingress.
* Avoid public IP addresses.

Node IAM permissions must be kept minimal.

---

# 25. Kubernetes IAM Integration

AWS access from Kubernetes workloads should use workload identity rather than distributing static AWS credentials.

The implementation should support:

* EKS OIDC
* IAM roles for service accounts/workloads
* Least-privilege policies

Examples:

```text
AWS Load Balancer Controller
        │
        └── IAM Role

External Secrets
        │
        └── IAM Role

OpenTelemetry / AWS integrations
        │
        └── IAM Role
```

---

# 26. ECR Architecture

The ECR module creates repositories for the application services.

Repositories:

```text
user-service
product-service
order-service
payment-service
```

Each repository should support:

* Image scanning
* Encryption
* Lifecycle policies
* Immutable image tags where appropriate
* Repository policies
* Controlled access

---

# 27. Container Image Lifecycle

A typical lifecycle:

```text
Developer
   │
   ▼
GitHub
   │
   ▼
CI Pipeline
   │
   ├── Test
   ├── SAST
   ├── Dependency Scan
   ├── Container Build
   ├── Trivy Scan
   │
   ▼
ECR
   │
   ▼
Argo CD
   │
   ▼
EKS
```

Terraform provisions the ECR infrastructure.

The CI pipeline manages image publication.

---

# 28. RDS PostgreSQL Architecture

RDS PostgreSQL provides the persistent relational data layer.

```text
                    EKS
                     │
                     ▼
              Application Services
                     │
                     ▼
              RDS PostgreSQL
                     │
              Multi-AZ Production
```

Production RDS should use:

* Multi-AZ deployment
* Private subnets
* Encryption
* Automated backups
* Point-in-time recovery
* Deletion protection
* Restricted security groups
* Parameter groups
* Backup retention
* Monitoring

---

# 29. Database Network Security

RDS should accept traffic only from approved application security groups.

Conceptually:

```text
EKS Application SG
       │
       │ PostgreSQL
       ▼
RDS Security Group
       │
       ▼
PostgreSQL
```

No:

```text
Internet → PostgreSQL
```

---

# 30. Redis / Valkey Architecture

The `redis` Terraform module manages the managed caching layer.

The implementation may use the AWS-supported Redis-compatible managed service selected for the project.

Responsibilities include:

* Cluster/subnet configuration
* Encryption
* Authentication
* Security groups
* Multi-AZ configuration
* Automatic failover where supported
* Parameter configuration
* Backup configuration where applicable

Redis/Valkey remains private.

---

# 31. KMS Architecture

The KMS module manages customer-managed encryption keys where required.

Potential key separation:

```text
KMS
│
├── EKS encryption key
├── RDS encryption key
├── Secrets Manager key
├── Logs key
└── Application/data key
```

Key separation may be reduced in lower environments to control operational complexity and cost.

Production should favor separation according to data classification and access boundaries.

---

# 32. KMS Key Policy

KMS key policies must explicitly control:

* Administrative access
* Terraform deployment access
* Service access
* Key usage
* Key rotation
* Deletion protection where applicable

Wildcard administrative permissions should be avoided.

---

# 33. Secrets Management

Secrets must never be stored in:

* Git
* Terraform variable files committed to Git
* Kubernetes manifests
* Dockerfiles
* Application source code

Terraform provisions the required Secrets Manager infrastructure.

Example:

```text
AWS Secrets Manager
│
├── database credentials
├── application secrets
├── external service credentials
└── integration secrets
```

Kubernetes workloads consume secrets through the External Secrets integration managed by GitOps.

---

# 34. Terraform and Secret Values

Terraform should create secret containers and metadata where possible without embedding actual secret values into source control.

Secret values should be supplied through secure deployment mechanisms.

The implementation must carefully avoid unnecessary exposure of secret values in Terraform state.

---

# 35. Observability Infrastructure

The Terraform observability module manages AWS-level observability dependencies.

Terraform does not deploy the complete Kubernetes observability stack.

The responsibilities are divided as follows.

## Terraform

* CloudWatch integration
* AWS log groups
* IAM permissions
* SNS/EventBridge integration
* S3 archival where required
* AWS-level alarms
* Observability infrastructure dependencies

## Argo CD

* Prometheus
* Grafana
* Loki
* Tempo
* OpenTelemetry Collector
* Alertmanager
* Kubernetes dashboards
* Kubernetes recording rules

---

# 36. Observability Architecture

```text
Applications
     │
     ├── Metrics
     ├── Logs
     └── Traces
     │
     ▼
OpenTelemetry / Prometheus
     │
     ├─────────────┐
     ▼             ▼
   Loki          Tempo
     │             │
     └──────┬──────┘
            ▼
         Grafana
            │
       Dashboards
       Alerts / SLOs
```

AWS infrastructure telemetry is integrated into the platform where required.

---

# 37. Environment Configuration

Each environment must define environment-specific values separately.

Example:

```text
environments/
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   ├── outputs.tf
│   └── backend.tf
│
├── staging/
│   ├── main.tf
│   ├── variables.tf
│   ├── terraform.tfvars.example
│   ├── outputs.tf
│   └── backend.tf
│
└── production/
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    ├── outputs.tf
    └── backend.tf
```

Sensitive values must not be committed.

---

# 38. Environment Differences

The same modules should be reused across environments.

Differences are expressed through configuration.

Example:

```text
                Module
                  │
       ┌──────────┼──────────┐
       ▼          ▼          ▼
      Dev      Staging   Production
       │          │          │
    smaller    medium     enterprise
    capacity   capacity    capacity
```

Production may use:

* More Availability Zones
* More node capacity
* Multi-AZ RDS
* Higher backup retention
* Stronger deletion protection
* Dedicated observability capacity
* More NAT infrastructure
* More aggressive monitoring

---

# 39. Terraform Dependency Graph

The infrastructure deployment order is logically:

```text
Global Backend
      │
      ▼
Global IAM
      │
      ▼
KMS
      │
      ▼
VPC
      │
      ├───────────────┐
      ▼               ▼
     IAM              ECR
      │
      ▼
     EKS
      │
      ├───────────────┐
      ▼               ▼
     RDS           Redis/Valkey
      │               │
      └───────┬───────┘
              ▼
       Observability
              │
              ▼
            Argo CD
              │
              ▼
        Kubernetes Stack
```

Terraform should rely primarily on implicit dependencies created through module inputs/outputs rather than excessive explicit `depends_on`.

---

# 40. Module Dependency Model

```text
VPC
 │
 ├── EKS
 │    └── IAM
 │
 ├── RDS
 │
 └── Redis

KMS
 │
 ├── EKS
 ├── RDS
 └── Secrets

ECR
 │
 └── CI/CD

Secrets
 │
 └── External Secrets

Observability
 │
 └── AWS integrations
```

---

# 41. Terraform Outputs

Modules should expose only useful outputs.

Examples:

## VPC

```text
vpc_id
private_subnet_ids
public_subnet_ids
database_subnet_ids
security_group_ids
```

## EKS

```text
cluster_id
cluster_name
cluster_endpoint
cluster_certificate_authority
oidc_provider_arn
```

## RDS

```text
endpoint
port
identifier
security_group_id
```

## Redis

```text
endpoint
port
security_group_id
```

Sensitive outputs must be explicitly marked sensitive.

---

# 42. Terraform Variables

Variables must have:

* Descriptions
* Types
* Validation rules where appropriate
* Sensible defaults only where safe

Example:

```text
variable "environment" {
  type        = string
  description = "Deployment environment."

  validation {
    condition = contains(
      ["dev", "staging", "production"],
      var.environment
    )

    error_message = "Environment must be dev, staging, or production."
  }
}
```

---

# 43. Naming Convention

Resources should follow a consistent naming pattern.

Recommended:

```text
observastack-${environment}-${component}
```

Examples:

```text
observastack-production-eks
observastack-production-rds
observastack-production-ecr
```

Names must remain within AWS service naming constraints.

---

# 44. Terraform Workflow

The standard developer workflow is:

```text
terraform fmt
      │
      ▼
terraform init
      │
      ▼
terraform validate
      │
      ▼
terraform plan
      │
      ▼
Code Review
      │
      ▼
terraform apply
```

Production changes must require review and controlled approval.

---

# 45. CI/CD Terraform Workflow

The CI pipeline should perform:

```text
Pull Request
     │
     ▼
Terraform Format
     │
     ▼
Terraform Validate
     │
     ▼
Lint
     │
     ▼
Security Scan
     │
     ▼
Terraform Plan
     │
     ▼
Review
     │
     ▼
Merge
     │
     ▼
Controlled Apply
```

The pipeline must fail when validation or security checks fail.

---

# 46. Terraform Security Validation

The Terraform pipeline should include infrastructure security analysis.

Candidate controls include:

* Terraform validation
* Terraform linting
* Static security analysis
* IAM policy analysis
* Secret detection
* Provider vulnerability checks
* Configuration policy checks

Tools may include:

```text
TFLint
Trivy
Checkov
Terraform native validation
```

The exact toolchain can evolve without changing the architecture.

---

# 47. Terraform Testing

Testing must operate at multiple levels.

## Static validation

```text
terraform fmt
terraform validate
```

## Module testing

```text
terraform test
```

## Security testing

```text
Trivy
Checkov
```

## Integration testing

Where practical:

```text
Terratest
```

## Infrastructure validation

Validate:

* VPC connectivity
* EKS cluster accessibility
* IAM permissions
* Database connectivity
* Redis connectivity
* Encryption
* Security group behavior

---

# 48. Production Deployment Controls

Production Terraform must include safeguards such as:

* Pull request review
* Protected branches
* Plan artifacts
* Approval before apply
* Restricted deployment role
* Audit logging
* State locking
* Backup protection
* Deletion protection for critical resources

Production infrastructure must never be modified through an unreviewed local apply.

---

# 49. Disaster Recovery

Terraform supports infrastructure recovery through reproducibility.

Recovery strategy:

```text
Git Repository
      │
      ▼
Terraform
      │
      ▼
AWS Infrastructure
      │
      ├── VPC
      ├── EKS
      ├── RDS
      ├── Redis
      └── Supporting Services
```

Terraform does not replace database backups.

RDS recovery relies on:

* Automated backups
* Point-in-time recovery
* Snapshot strategy
* Multi-AZ deployment
* Optional cross-region replication where required

---

# 50. Terraform State Disaster Recovery

Terraform state must have:

* S3 versioning
* Encryption
* Access controls
* Backup/recovery capability

A state recovery procedure must be documented.

---

# 51. Cost Management

Terraform must support environment-specific cost optimization.

Examples:

## Development

* Smaller node groups
* Reduced database capacity
* Reduced NAT infrastructure where acceptable
* Smaller Redis capacity
* Shorter log retention

## Staging

* Production-like topology
* Reduced capacity
* Production-like deployment architecture

## Production

* Multi-AZ
* High availability
* Appropriate redundancy
* Longer backup retention
* Production-grade monitoring

Cost optimization must not compromise required production availability or security.

---

# 52. FinOps Considerations

Terraform resources should be tagged consistently so costs can be attributed to:

* Environment
* Component
* Service
* Team
* Project

The observability stack will later expose infrastructure and application cost information through the FinOps dashboards defined in the repository.

---

# 53. Security Boundaries

The infrastructure should implement the following trust boundaries:

```text
Internet
   │
   ▼
Public Load Balancer
   │
   ▼
EKS
   │
   ├──────────► RDS
   │
   ├──────────► Redis
   │
   └──────────► AWS Services
```

Security controls exist at:

1. AWS account
2. VPC
3. Subnet
4. Security group
5. IAM
6. KMS
7. EKS
8. Kubernetes
9. Application

---

# 54. Terraform / Kubernetes Boundary

This boundary is critical.

```text
                Terraform
                    │
       AWS Infrastructure Layer
                    │
                    ▼
                  EKS
                    │
              ──────┼──────
                    │
                 Argo CD
                    │
                    ▼
             Kubernetes Layer
```

Terraform creates the platform.

Argo CD manages what runs on the platform.

This prevents Terraform from becoming a monolithic Kubernetes deployment mechanism.

---

# 55. Implementation Structure

The final Terraform implementation must produce:

```text
terraform/
│
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── rds/
│   ├── redis/
│   ├── ecr/
│   ├── iam/
│   ├── kms/
│   ├── secrets/
│   └── observability/
│
├── environments/
│   ├── dev/
│   ├── staging/
│   └── production/
│
└── global/
    ├── backend/
    └── iam/
```

No module should duplicate the complete infrastructure configuration of another module.

---

# 56. Implementation Order

Terraform implementation will proceed in the following order.

## Phase 1 — Terraform foundation

```text
global/backend
global/iam
```

## Phase 2 — Security foundation

```text
kms
iam
secrets
```

## Phase 3 — Networking

```text
vpc
```

## Phase 4 — Container platform

```text
ecr
eks
```

## Phase 5 — Data layer

```text
rds
redis
```

## Phase 6 — AWS observability integration

```text
observability
```

## Phase 7 — Environments

```text
dev
staging
production
```

## Phase 8 — Validation

```text
terraform tests
security scanning
CI/CD
```

---

# 57. Acceptance Criteria

Volume 4 is considered successfully implemented when:

### Terraform foundation

* [ ] Remote Terraform state exists.
* [ ] State is encrypted.
* [ ] State versioning is enabled.
* [ ] State locking is enabled.
* [ ] Environment state is isolated.

### Networking

* [ ] VPC is provisioned through Terraform.
* [ ] Public subnets exist.
* [ ] Private subnets exist.
* [ ] Data/isolated subnets exist.
* [ ] Route tables are correctly associated.
* [ ] NAT architecture is implemented.
* [ ] VPC endpoints are implemented where justified.

### EKS

* [ ] EKS cluster is provisioned.
* [ ] Worker nodes run in private subnets.
* [ ] Multi-AZ deployment is supported.
* [ ] Cluster encryption is enabled.
* [ ] IAM workload integration is implemented.
* [ ] Node groups are managed through Terraform.

### ECR

* [ ] Application repositories exist.
* [ ] Image scanning is enabled.
* [ ] Lifecycle policies exist.
* [ ] Repository access is restricted.

### Database

* [ ] PostgreSQL is private.
* [ ] Encryption is enabled.
* [ ] Backups are enabled.
* [ ] Production supports Multi-AZ.
* [ ] Database access is restricted through security groups.

### Redis

* [ ] Redis/Valkey is private.
* [ ] Encryption is enabled.
* [ ] Authentication is configured.
* [ ] Production supports high availability.

### Security

* [ ] KMS keys are provisioned.
* [ ] IAM follows least privilege.
* [ ] Secrets are not committed to Git.
* [ ] Public database access is disabled.
* [ ] Terraform security scanning is implemented.

### Observability

* [ ] AWS-level observability resources are provisioned.
* [ ] Kubernetes observability remains GitOps-managed.
* [ ] Required IAM integrations exist.
* [ ] Logging/monitoring integrations are supported.

### CI/CD

* [ ] Terraform formatting is automated.
* [ ] Validation is automated.
* [ ] Linting is automated.
* [ ] Security scanning is automated.
* [ ] Plan is generated for pull requests.
* [ ] Production apply is controlled.

### Documentation

* [ ] Every module has documentation.
* [ ] Every environment has documented deployment instructions.
* [ ] Disaster recovery is documented.
* [ ] Terraform operational procedures are documented.

---

# 58. Final Terraform Architecture

The completed infrastructure architecture is:

```text
                         AWS
                          │
                  ┌───────┴────────┐
                  │                 │
              Global            Environment
                  │                 │
             ┌────┴────┐      ┌────┴─────────────┐
             │         │      │                  │
          Backend     IAM     VPC               KMS
                               │                  │
                    ┌──────────┼──────────┐       │
                    │          │          │       │
                 Public     Private      Data     │
                    │          │          │       │
                   ALB        EKS        RDS      │
                              │           │        │
                              │         Redis      │
                              │                    │
                              └────────┬───────────┘
                                       │
                                      ECR
                                       │
                                  Observability
                                       │
                                       ▼
                                      EKS
                                       │
                                     ArgoCD
                                       │
             ┌─────────────────────────┼─────────────────────────┐
             │                         │                         │
       Microservices             Observability              Platform
             │                         │                         │
       ┌─────┼─────┐          ┌────────┼─────────┐          Ingress
       │     │     │          │        │         │          Secrets
      User Product Order    Prometheus Grafana  OTel       Autoscaling
                         Loki / Tempo / Alertmanager
```

This architecture establishes a clean separation between:

**Infrastructure → Kubernetes platform → workloads → observability.**

---

# 59. Volume 4 Completion Statement

Volume 4 defines the Terraform contract for ObservaStack.

The implementation that follows must satisfy this specification without introducing unnecessary architectural changes.

The Terraform layer is therefore the **AWS infrastructure foundation** upon which the Kubernetes, GitOps, observability, security, resilience and application layers defined in later volumes will operate.
