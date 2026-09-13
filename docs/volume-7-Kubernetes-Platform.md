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

## ## Objective

Provide a stable, policy-aware Kubernetes baseline immediately after the EKS cluster is provisioned by Terraform.

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
---


## Design principles

1. Kubernetes manifests are declarative and Kustomize-compatible.
2. The foundation is environment-neutral.
3. GitOps is the intended ownership model for Kubernetes workloads.
4. Terraform owns AWS infrastructure, not application workload manifests.
5. Security policy is introduced progressively instead of creating hidden dependencies between phases.
6. Namespaces provide the first logical isolation boundary.
7. PriorityClasses provide explicit workload scheduling intent without changing the cluster-wide default priority.

---

## Namespace model

| Namespace | Purpose | PSA enforce |
|---|---|---|
| `observastack` | Microservices and application workloads | `restricted` |
| `observability` | Prometheus, Grafana, Loki, Tempo, OTel and Alertmanager | `restricted` |
| `platform-system` | Platform controllers and supporting components | `baseline` |

The Kubernetes control-plane namespaces such as `kube-system` are not recreated by this package.

---

## Ownership

```text
Terraform
  -> EKS cluster / AWS resources

Kubernetes foundation
  -> baseline cluster objects

Argo CD
  -> desired-state reconciliation in later phases

Application teams
  -> application manifests through GitOps
```

---

## Why no NetworkPolicy yet?

NetworkPolicy is intentionally deferred to Step 7.4 so that the foundation does not accidentally deny traffic required by controllers before their complete communication requirements are known.

## Why no ResourceQuota yet?

Quotas and LimitRanges are deferred to Step 7.3 because their values should be established from the resource sizing model for each environment.
---

## Implementation Checklist

- [x] Kustomize root created
- [x] Application namespace created
- [x] Observability namespace created
- [x] Platform namespace created
- [x] Pod Security Admission labels defined
- [x] Standard ObservaStack ownership labels defined
- [x] Platform PriorityClass defined
- [x] Application PriorityClass defined
- [x] Validation script added
- [x] Documentation added
- [x] No Terraform workload duplication introduced
- [x] No Argo CD installation introduced
- [x] No application manifests introduced

---