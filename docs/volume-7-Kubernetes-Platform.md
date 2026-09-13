# Enterprise Cloud Observability & SRE Platform

## EKS / Kubernetes Platform

**Project Name:** ObservaStack
**Architecture Version:** 1.0
**Document Status:** Proposed / Target Architecture
**Primary Cloud:** Amazon Web Services (AWS)
**Container Platform:** Amazon Elastic Kubernetes Service (EKS)
**Infrastructure as Code:** Terraform
**GitOps:** Argo CD
**Telemetry Standard:** OpenTelemetry
**Observability:** Prometheus, Grafana, Loki, Tempo
**CI/CD:** GitHub Actions

---
In Volume 6 work, EKS itself was already implemented as Terraform module 6.6. So Step 7 should not rebuild the EKS infrastructure.

Instead, Step 7 should be the Kubernetes/EKS platform layer that runs on top of the AWS infrastructure.

---

The architecture should now progress like this:

```
STEP 6 — Terraform / AWS Infrastructure
                │
                ▼
        ┌───────────────────┐
        │        AWS        │
        │                   │
        │ VPC               │
        │ EKS               │
        │ RDS               │
        │ Redis             │
        │ ECR               │
        │ IAM               │
        │ KMS               │
        │ Secrets Manager   │
        └─────────┬─────────┘
                  │
                  ▼
STEP 7 — EKS / Kubernetes Platform
                  │
        ┌─────────┴─────────┐
        │                   │
   Platform Layer      Observability
        │                   │
        ▼                   ▼
   Ingress              Prometheus
   cert-manager         Grafana
   External Secrets     Loki
   Autoscaling          Tempo
   Network Policies     OpenTelemetry
   Namespaces            Alertmanager
        │
        ▼
STEP 8 — GitOps / Argo CD
        │
        ▼
STEP 9 — Microservices
        │
        ▼
STEP 10 — Observability / SRE
```

---
## Kubernetes Platform Engineering phase:

```
7.1  Kubernetes foundation
7.2  Namespaces
7.3  Resource quotas & LimitRanges
7.4  Network policies
7.5  Pod security
7.6  Ingress / AWS Load Balancer Controller
7.7  cert-manager
7.8  External Secrets
7.9  Kubernetes autoscaling
7.10 Storage / EBS CSI
7.11 EKS Pod Identity
7.12 Cluster platform configuration
7.13 Argo CD prerequisites
7.14 Platform security
7.15 Platform validation
```