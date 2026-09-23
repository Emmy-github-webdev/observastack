# Cluster Platform Configuration

This directory contains Kubernetes-side platform conventions. It does not replace Terraform-managed EKS add-ons.

Terraform-owned add-ons:
- VPC CNI
- CoreDNS
- kube-proxy
- EBS CSI
- EKS Pod Identity Agent

Metrics Server and later platform controllers can be deployed through the GitOps path.
