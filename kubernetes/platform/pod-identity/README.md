# Pod Identity Kubernetes Contract

EKS Pod Identity associations are AWS/EKS resources. This directory contains only the Kubernetes-side ServiceAccount contract.

Terraform owns the IAM role and association.

ServiceAccount names must remain stable because the association targets the ServiceAccount identity.
