# Enterprise Cloud Observability Platform

## Repository Design Specification

**Project:** ObservaStack
**Document:** Volume 3 — Repository Design
**Version:** 1.0
**Status:** Baseline Repository Architecture
**Primary Cloud:** AWS
**Infrastructure as Code:** Terraform
**Container Platform:** Amazon EKS
**Application Platform:** Kubernetes Microservices
**Observability Standard:** OpenTelemetry
**GitOps Platform:** Argo CD

---

# 1. Purpose

This document defines the repository architecture for the ObservaStack Enterprise Cloud Observability Platform.

The repository must support the complete engineering lifecycle:

```text
Infrastructure
     ↓
Platform
     ↓
Applications
     ↓
Observability
     ↓
Security
     ↓
GitOps
     ↓
Testing
     ↓
Operations
```

The repository is intentionally designed as a **single-repository platform engineering project**.

This allows the portfolio project to demonstrate the relationship between infrastructure, applications, observability, GitOps, security, reliability engineering, and operational practices in one cohesive system.

---

# 2. Repository Strategy

ObservaStack will initially use a **monorepo architecture**.

```text
One GitHub Repository
        │
        ├── Infrastructure
        ├── Applications
        ├── Kubernetes
        ├── GitOps
        ├── Observability
        ├── Security
        ├── Testing
        └── Documentation
```

Repository:

```text
observastack/
```

The monorepo is appropriate for this portfolio implementation because the project is intended to demonstrate the complete platform lifecycle rather than operate as multiple independently owned production repositories.

---

# 3. Repository Design Principles

The repository shall follow these principles.

## 3.1 Separation of Concerns

Infrastructure, application source code, deployment configuration, observability configuration, and documentation shall have clearly defined boundaries.

---

## 3.2 Infrastructure as Code

All provisionable infrastructure shall be represented as code.

```text
AWS Infrastructure
        ↓
Terraform
        ↓
Git
```

No manually created production infrastructure should be required for normal operation.

---

## 3.3 GitOps

Kubernetes desired state shall be represented declaratively in Git.

```text
Git
 ↓
Argo CD
 ↓
EKS
```

---

## 3.4 Environment Isolation

Development, staging, and production configuration shall be explicitly separated.

---

## 3.5 Version Control

The following must be version controlled:

* Terraform
* Kubernetes manifests
* Helm configuration
* GitOps configuration
* Dashboards
* Alert rules
* Application source
* Security policies
* Runbooks
* Architecture decisions

---

## 3.6 Reproducibility

A new engineer should be able to clone the repository and understand:

1. What the platform does.
2. How it is structured.
3. How infrastructure is provisioned.
4. How applications are built.
5. How applications are deployed.
6. How observability works.
7. How incidents are investigated.

---

# 4. Target Repository Structure

The final repository shall use the following structure:

```text
observastack/
│
├── README.md
├── CONTRIBUTING.md
├── SECURITY.md
├── LICENSE
├── Makefile
├── .gitignore
├── .editorconfig
│
├── architecture/
│   ├── architecture.drawio
│   ├── architecture.png
│   ├── context/
│   ├── diagrams/
│   └── decisions/
│       ├── ADR-001-terraform.md
│       ├── ADR-002-eks.md
│       ├── ADR-003-opentelemetry.md
│       ├── ADR-004-prometheus.md
│       ├── ADR-005-loki.md
│       ├── ADR-006-tempo.md
│       ├── ADR-007-grafana.md
│       ├── ADR-008-argocd.md
│       ├── ADR-009-repository-strategy.md
│       └── ADR-010-multi-az.md
│
├── terraform/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── eks/
│   │   ├── rds/
│   │   ├── redis/
│   │   ├── ecr/
│   │   ├── iam/
│   │   ├── kms/
│   │   ├── secrets/
│   │   └── observability/
│   │
│   ├── environments/
│   │   ├── dev/
│   │   ├── staging/
│   │   └── production/
│   │
│   └── global/
│       ├── backend/
│       └── iam/
│
├── services/
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   └── payment-service/
│
├── kubernetes/
│   ├── base/
│   │   ├── namespaces/
│   │   ├── config/
│   │   ├── network-policies/
│   │   └── resource-policies/
│   │
│   ├── platform/
│   │   ├── ingress/
│   │   ├── cert-manager/
│   │   ├── external-secrets/
│   │   └── autoscaling/
│   │
│   └── observability/
│       ├── collectors/
│       ├── metrics/
│       ├── logging/
│       ├── tracing/
│       ├── alerting/
│       └── dashboards/
│
├── gitops/
│   ├── bootstrap/
│   ├── projects/
│   │
│   ├── applications/
│   │   ├── user-service/
│   │   ├── product-service/
│   │   ├── order-service/
│   │   └── payment-service/
│   │
│   ├── observability/
│   │   ├── prometheus/
│   │   ├── grafana/
│   │   ├── loki/
│   │   ├── tempo/
│   │   ├── opentelemetry/
│   │   └── alertmanager/
│   │
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── production/
│
├── observability/
│   ├── dashboards/
│   │   ├── platform.json
│   │   ├── kubernetes.json
│   │   ├── application.json
│   │   ├── database.json
│   │   ├── slo.json
│   │   └── cost.json
│   │
│   ├── alerts/
│   │   ├── infrastructure.yaml
│   │   ├── kubernetes.yaml
│   │   ├── application.yaml
│   │   ├── database.yaml
│   │   └── slo.yaml
│   │
│   ├── recording-rules/
│   │
│   ├── slo/
│   │
│   └── otel/
│       ├── collectors/
│       ├── pipelines/
│       ├── processors/
│       └── exporters/
│
├── security/
│   ├── policies/
│   ├── trivy/
│   ├── terraform/
│   ├── kubernetes/
│   └── secrets/
│
├── chaos/
│   ├── pod-failure.yaml
│   ├── cpu-stress.yaml
│   ├── network-failure.yaml
│   └── experiments/
│
├── tests/
│   ├── terraform/
│   ├── kubernetes/
│   ├── services/
│   ├── observability/
│   ├── security/
│   ├── resilience/
│   └── end-to-end/
│
├── docs/
│   ├── getting-started.md
│   ├── development.md
│   ├── deployment.md
│   ├── disaster-recovery.md
│   ├── security.md
│   ├── slo.md
│   ├── finops.md
│   ├── observability-strategy.md
│   │
│   ├── runbooks/
│   │   ├── high-error-rate.md
│   │   ├── high-latency.md
│   │   ├── pod-crashloop.md
│   │   ├── node-failure.md
│   │   ├── database-degradation.md
│   │   └── payment-failure.md
│   │
│   └── incident-reports/
│       └── templates/
│
└── .github/
    ├── workflows/
    │   ├── terraform.yml
    │   ├── services-ci.yml
    │   ├── security.yml
    │   ├── gitops-validation.yml
    │   └── observability-validation.yml
    │
    ├── CODEOWNERS
    ├── pull_request_template.md
    └── ISSUE_TEMPLATE/
```

---

# 5. Repository Responsibility Model

Each top-level directory has a specific responsibility.

| Directory        | Responsibility                                       |
| ---------------- | ---------------------------------------------------- |
| `architecture/`  | Architecture and design decisions                    |
| `terraform/`     | AWS infrastructure                                   |
| `applications/`  | Microservice source code                             |
| `kubernetes/`    | Kubernetes platform configuration                    |
| `gitops/`        | Argo CD desired state                                |
| `observability/` | Dashboards, alerts, SLOs and telemetry configuration |
| `security/`      | Security policies and scanning configuration         |
| `chaos/`         | Resilience experiments                               |
| `tests/`         | Automated validation                                 |
| `docs/`          | Operational and engineering documentation            |
| `.github/`       | CI/CD and repository governance                      |

This separation is intentional.

---

# 6. Infrastructure Repository Design

The Terraform directory is responsible only for infrastructure provisioning.

```text
terraform/
│
├── modules/
│
├── environments/
│
└── global/
```

Terraform should not contain application source code.

---

# 7. Terraform Modules

Reusable infrastructure components shall be implemented as modules.

```text
terraform/modules/
```

Initial modules:

```text
vpc/
eks/
iam/
ecr/
rds/
redis/
kms/
secrets/
observability/
```

Each module should follow a consistent structure:

```text
module-name/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── locals.tf
└── README.md
```

Where appropriate, modules may additionally contain:

```text
data.tf
iam.tf
security-groups.tf
```

---

# 8. Environment Structure

Terraform environments shall be isolated.

```text
terraform/environments/

├── dev/
├── staging/
└── production/
```

Each environment should contain:

```text
main.tf
variables.tf
outputs.tf
providers.tf
backend.tf
terraform.tfvars.example
```

Production shall not depend on manually modified local Terraform state.

---

# 9. Terraform State

Terraform state shall be managed remotely.

The repository shall never contain:

```text
*.tfstate
*.tfstate.backup
```

State configuration shall be separated from application source code.

---

# 10. Application Repository Design

Application source code shall live under:

```text
applications/
```

Each service shall be independently buildable.

Example:

```text
applications/payment-service/
│
├── src/
├── tests/
├── Dockerfile
├── package.json
├── README.md
└── ...
```

The exact language/framework can vary by service, but the service contract must remain consistent.

---

# 11. Application Responsibilities

Applications are responsible for:

* Business logic
* API endpoints
* Application metrics
* Structured logging
* Distributed tracing
* Health checks
* Unit tests
* Containerization

Applications shall **not** contain infrastructure provisioning logic.

---

# 12. Kubernetes Repository Design

The Kubernetes directory represents platform-level Kubernetes configuration.

```text
kubernetes/
```

It is distinct from GitOps.

The conceptual separation is:

```text
kubernetes/
     │
     └── Kubernetes building blocks

gitops/
     │
     └── What should be deployed and where
```

This distinction prevents the repository from mixing platform configuration with deployment orchestration.

---

# 13. Kubernetes Base Configuration

The base directory contains reusable Kubernetes configuration.

```text
kubernetes/base/
```

Examples:

```text
namespaces/
config/
network-policies/
resource-policies/
```

---

# 14. Platform Services

Platform services shall be organized under:

```text
kubernetes/platform/
```

Examples:

```text
ingress/
cert-manager/
external-secrets/
autoscaling/
```

These components support application workloads but are not themselves business applications.

---

# 15. Observability Kubernetes Configuration

Observability workloads shall be grouped under:

```text
kubernetes/observability/
```

Examples:

```text
collectors/
metrics/
logging/
tracing/
alerting/
dashboards/
```

---

# 16. GitOps Repository Design

GitOps configuration shall live under:

```text
gitops/
```

Argo CD shall use this directory as the declarative deployment source.

---

# 17. GitOps Bootstrap

The bootstrap directory contains the initial configuration required to install and configure Argo CD.

```text
gitops/bootstrap/
```

The objective is:

```text
Fresh EKS Cluster
        ↓
Bootstrap
        ↓
Argo CD
        ↓
Applications
        ↓
Observability
```

---

# 18. GitOps Projects

Argo CD projects shall be defined under:

```text
gitops/projects/
```

Projects should provide logical boundaries between:

* Platform
* Applications
* Observability

---

# 19. GitOps Applications

Application deployment definitions shall live under:

```text
gitops/applications/
```

Examples:

```text
user-service
product-service
order-service
payment-service
```

---

# 20. Environment Deployment Model

GitOps environments shall be represented explicitly.

```text
gitops/environments/
├── dev/
├── staging/
└── production/
```

The desired deployment state should therefore be visible in Git.

---

# 21. Observability Repository Design

Observability configuration deserves its own top-level domain.

```text
observability/
```

This is intentionally separate from infrastructure and application code.

It represents the **observability-as-code layer**.

---

# 22. Dashboard as Code

Grafana dashboards shall be stored as code.

```text
observability/dashboards/
```

Initial dashboards:

```text
platform.json
kubernetes.json
application.json
database.json
slo.json
cost.json
```

Dashboards must be version controlled.

---

# 23. Alert as Code

Alert rules shall be stored under:

```text
observability/alerts/
```

Example:

```text
infrastructure.yaml
kubernetes.yaml
application.yaml
database.yaml
slo.yaml
```

Alert configuration shall be reviewable through Git pull requests.

---

# 24. Recording Rules

Frequently used Prometheus calculations shall be stored under:

```text
observability/recording-rules/
```

This prevents complex queries from being duplicated across dashboards and alerts.

---

# 25. SLO Configuration

SLO definitions shall live under:

```text
observability/slo/
```

Each critical service should eventually have defined:

```text
SLI
SLO
Error Budget
Burn Rate
```

Example:

```text
payment-service/
order-service/
api-gateway/
```

---

# 26. OpenTelemetry Configuration

OpenTelemetry configuration shall live under:

```text
observability/otel/
```

This directory may contain:

```text
collectors/
pipelines/
processors/
exporters/
```

The objective is to make telemetry architecture explicit and version controlled.

---

# 27. Security Repository Design

Security controls shall be treated as code.

```text
security/
```

Security configuration shall include:

```text
security/
├── policies/
├── trivy/
├── terraform/
├── kubernetes/
└── secrets/
```

No real secrets shall be stored here.

---

# 28. Secrets Management

The repository may contain:

* Secret templates
* Secret schemas
* External Secrets configuration
* Documentation

It shall never contain:

* Passwords
* API keys
* AWS credentials
* Private keys
* Production tokens

---

# 29. Chaos Engineering Repository Design

Chaos experiments shall be isolated.

```text
chaos/
```

Initial experiments:

```text
pod-failure.yaml
cpu-stress.yaml
network-failure.yaml
```

Each experiment should map back to:

```text
Hypothesis
   ↓
Failure
   ↓
Telemetry
   ↓
Alert
   ↓
Recovery
```

---

# 30. Testing Repository Design

Testing shall be treated as a first-class engineering concern.

```text
tests/
```

Test categories:

```text
terraform/
kubernetes/
application/
observability/
security/
resilience/
end-to-end/
```

---

# 31. Infrastructure Testing

Terraform tests shall validate:

* Module configuration
* Required variables
* Outputs
* Security configuration
* Environment configuration

---

# 32. Kubernetes Testing

Kubernetes validation shall verify:

* Manifest validity
* Required resources
* Security policies
* Resource requests/limits
* Health probes
* Deployment configuration

---

# 33. Observability Testing

Observability tests shall verify:

```text
Metrics arrive
Logs arrive
Traces arrive
Correlation works
Alerts fire
Dashboards render
SLO calculations work
```

---

# 34. End-to-End Testing

End-to-end testing shall validate the complete operational chain.

Example:

```text
HTTP Request
    ↓
Application
    ↓
Metric
    ↓
Trace
    ↓
Log
    ↓
Alert
    ↓
Dashboard
```

---

# 35. Documentation Architecture

Documentation shall live under:

```text
docs/
```

Documentation is part of the platform rather than an afterthought.

Required documentation includes:

```text
Getting Started
Development
Deployment
Observability Strategy
Disaster Recovery
Security
FinOps
Runbooks
Incident Reports
```

---

# 36. Runbook Architecture

Every important production alert should eventually have an associated runbook.

Example:

```text
Alert
 ↓
Runbook
 ↓
Investigation
 ↓
Mitigation
 ↓
Recovery
 ↓
Validation
```

Example runbooks:

```text
high-error-rate.md
high-latency.md
pod-crashloop.md
node-failure.md
database-degradation.md
payment-failure.md
```

---

# 37. Architecture Decision Records

Architecture decisions shall be documented under:

```text
architecture/decisions/
```

Initial ADRs:

```text
ADR-001-monorepo.md
ADR-002-terraform.md
ADR-003-eks.md
ADR-004-opentelemetry.md
ADR-005-gitops.md
ADR-006-observability-backends.md
```

Each ADR should explain:

```text
Context
Decision
Alternatives
Consequences
```

---

# 38. GitHub Actions Architecture

CI/CD workflows shall live under:

```text
.github/workflows/
```

Initial pipelines:

```text
terraform.yml
application-ci.yml
security.yml
gitops-validation.yml
observability-validation.yml
```

---

# 39. Terraform Pipeline

The Terraform workflow should implement:

```text
Pull Request
     ↓
terraform fmt
     ↓
terraform validate
     ↓
security scan
     ↓
terraform plan
     ↓
Review
     ↓
Apply
```

Production apply should require appropriate approval.

---

# 40. Application CI Pipeline

The application pipeline should implement:

```text
Commit
  ↓
Unit Tests
  ↓
Code Quality
  ↓
Dependency Scan
  ↓
Container Build
  ↓
Container Scan
  ↓
Push Image
```

Images shall be published to Amazon ECR.

---

# 41. GitOps Deployment Flow

Application deployment shall follow:

```text
Developer
    ↓
Git Commit
    ↓
GitHub Actions
    ↓
Build Image
    ↓
Security Scan
    ↓
Push Image
    ↓
Update Deployment Configuration
    ↓
GitOps Repository
    ↓
Argo CD
    ↓
EKS
```

---

# 42. Production Change Flow

Production infrastructure changes:

```text
Engineer
   ↓
Pull Request
   ↓
CI Validation
   ↓
Terraform Plan
   ↓
Code Review
   ↓
Approval
   ↓
Terraform Apply
```

Production application changes:

```text
Developer
   ↓
Pull Request
   ↓
CI
   ↓
Container Image
   ↓
GitOps Change
   ↓
Review
   ↓
Argo CD
   ↓
EKS
```

---

# 43. Repository Ownership

`CODEOWNERS` shall establish ownership boundaries.

Conceptually:

```text
terraform/       → Platform Engineering
applications/    → Application Engineering
kubernetes/      → Platform Engineering
gitops/          → Platform Engineering
observability/   → SRE
security/        → Security / Platform
docs/runbooks/   → SRE
```

For the portfolio project, these can initially map to the project owner while still demonstrating enterprise governance.

---

# 44. Branching Strategy

The project shall use a protected main branch.

Recommended model:

```text
main
 │
 ├── feature/*
 ├── fix/*
 └── chore/*
```

Changes shall be introduced through pull requests.

Direct production changes should not bypass version control.

---

# 45. Commit Convention

Commits should follow a consistent convention.

Example:

```text
feat: add payment service tracing
fix: correct prometheus alert rule
feat: add production EKS node group
chore: update grafana dashboard
docs: add database degradation runbook
security: update container scanning policy
```

---

# 46. Repository Quality Gates

Pull requests should validate relevant domains.

### Terraform changes

```text
fmt
validate
lint
security scan
plan
```

### Application changes

```text
test
lint
quality scan
dependency scan
container scan
```

### Kubernetes changes

```text
manifest validation
security validation
policy validation
```

### Observability changes

```text
alert validation
dashboard validation
PromQL validation
configuration validation
```

---

# 47. Dependency Boundaries

The repository shall enforce the following conceptual dependencies:

```text
Terraform
   ↓
AWS Infrastructure
   ↓
EKS
   ↓
Platform Services
   ↓
Applications
   ↓
Observability
```

GitOps controls deployment state:

```text
GitOps
   ↓
Kubernetes
```

Observability observes the entire platform:

```text
                    Observability
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
     AWS Platform    Kubernetes    Applications
```

---

# 48. What Should NOT Be Mixed

The following boundaries must remain clear.

### Terraform should not contain:

* Application source
* Grafana dashboards
* Business logic

### Application code should not contain:

* Terraform
* AWS infrastructure provisioning
* Argo CD configuration

### GitOps should not contain:

* Terraform infrastructure
* Application business logic

### Dashboards should not contain:

* Hardcoded production credentials
* Infrastructure provisioning logic

### Documentation should not become:

* The source of truth for deployable configuration

Git remains the source of truth for configuration.

---

# 49. Local Developer Experience

The repository should provide a simple developer interface.

The `Makefile` may expose commands such as:

```text
make init
make validate
make test
make lint
make security
make build
make docker-build
make terraform-plan
make kube-validate
make observability-validate
```

The objective is to hide unnecessary command complexity while retaining transparent underlying tooling.

---

# 50. README Architecture

The root README should provide a high-level entry point.

Recommended structure:

```text
ObservaStack
│
├── What is ObservaStack?
├── Architecture
├── Features
├── Technology Stack
├── Repository Structure
├── Getting Started
├── Local Development
├── Infrastructure Deployment
├── GitOps
├── Observability
├── Security
├── SRE
├── Chaos Engineering
├── Disaster Recovery
├── FinOps
└── Documentation
```

The README should link deeper documentation rather than becoming a 100-page document.

---

# 51. Repository Onboarding Flow

A new engineer should be able to follow:

```text
README
  ↓
Architecture
  ↓
Requirements
  ↓
Repository Structure
  ↓
Getting Started
  ↓
Terraform
  ↓
EKS
  ↓
Applications
  ↓
GitOps
  ↓
Observability
  ↓
Runbooks
```

---

# 52. Repository-to-Platform Mapping

The repository should map directly to the platform architecture.

| Platform Layer     | Repository                  |
| ------------------ | --------------------------- |
| AWS Infrastructure | `terraform/`                |
| Kubernetes         | `kubernetes/`               |
| Applications       | `applications/`             |
| GitOps             | `gitops/`                   |
| Metrics            | `observability/`            |
| Logs               | `observability/`            |
| Traces             | `observability/`            |
| Dashboards         | `observability/dashboards/` |
| Alerts             | `observability/alerts/`     |
| SLOs               | `observability/slo/`        |
| Security           | `security/`                 |
| Chaos              | `chaos/`                    |
| Tests              | `tests/`                    |
| Operations         | `docs/runbooks/`            |
| Architecture       | `architecture/`             |

---

# 53. Repository Lifecycle

The repository supports the complete lifecycle:

```text
PLAN
 │
 ▼
Architecture
 │
 ▼
Requirements
 │
 ▼
DESIGN
 │
 ▼
Repository
 │
 ▼
BUILD
 │
 ▼
Terraform
 │
 ▼
AWS
 │
 ▼
EKS
 │
 ▼
Applications
 │
 ▼
GitOps
 │
 ▼
OPERATE
 │
 ▼
Observability
 │
 ▼
SRE
 │
 ▼
Incident Response
 │
 ▼
IMPROVE
 │
 ▼
Chaos / DR / Optimization
```

---

# 54. Repository Design Acceptance Criteria

The repository design shall be considered complete when:

* Infrastructure has a dedicated Terraform boundary.
* Terraform uses reusable modules.
* Environments are separated.
* Applications are independently organized.
* Kubernetes platform configuration is separated from GitOps.
* GitOps configuration is declarative.
* Observability configuration is version controlled.
* Dashboards are treated as code.
* Alerts are treated as code.
* SLOs are represented as code/configuration.
* Security controls are represented as code.
* Chaos experiments are version controlled.
* Tests are organized by engineering domain.
* Runbooks are version controlled.
* ADRs document major architectural decisions.
* CI/CD workflows validate changes.
* Repository ownership is defined.
* Secrets are excluded from Git.
* Production changes require appropriate review.
* A new engineer can understand the platform from the repository structure.

---

# 55. Final Repository Model

The resulting repository represents an **Internal Developer Platform / SRE platform** rather than simply a monitoring project.

```text
                         OBSERVASTACK
                              │
          ┌───────────────────┼───────────────────┐
          │                   │                   │
          ▼                   ▼                   ▼
   Infrastructure        Applications         Platform
    Terraform            Microservices       Kubernetes
          │                   │                   │
          └───────────────────┼───────────────────┘
                              │
                              ▼
                           GitOps
                          Argo CD
                              │
                              ▼
                             EKS
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
           Metrics          Logs            Traces
              │               │               │
              └───────────────┼───────────────┘
                              ▼
                         Observability
                              │
             ┌────────────────┼────────────────┐
             ▼                ▼                ▼
          Dashboards        Alerts             SLO
             │                │                │
             └────────────────┼────────────────┘
                              ▼
                             SRE
                              │
                ┌─────────────┼─────────────┐
                ▼             ▼             ▼
             Incident         DR          Chaos
             Response
```

---

# 56. Volume 3 Conclusion

The ObservaStack repository is designed as a cohesive enterprise platform engineering monorepo.

Its primary architectural principle is:

> **Infrastructure, applications, deployment, observability, security, testing, and operations are independently organized but connected through Git and automation.**

The repository therefore becomes more than a place to store source code.

It becomes the **operational blueprint of the entire platform**.

The progression is now:

```text
VOLUME 1
Architecture
     ↓
VOLUME 2
Requirements
     ↓
VOLUME 3
Repository Design
     ↓
VOLUME 4
Infrastructure Implementation
     ↓
VOLUME 5
Application + GitOps Implementation
     ↓
VOLUME 6
Observability + SRE
     ↓
VOLUME 7
Security + DR + Chaos + FinOps
     ↓
VOLUME 8
Testing + Evidence + Portfolio Presentation
```

The next engineering step is therefore **Volume 4 — Infrastructure Implementation**, where the repository design is converted into the actual AWS/Terraform architecture: account/environment strategy, VPC, subnets, NAT, VPC endpoints, IAM, EKS, RDS PostgreSQL, Redis, ECR, KMS, Secrets Manager, remote Terraform state, and the security boundaries between them.
