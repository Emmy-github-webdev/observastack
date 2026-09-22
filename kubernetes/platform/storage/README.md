# Kubernetes Storage

Terraform owns AWS storage infrastructure and the EKS EBS CSI add-on. These manifests assume the driver is already available.

Storage classes:
- `observastack-ebs-gp3`
- `observastack-ebs-gp3-retain`

Use the Retain class deliberately because released EBS volumes then require explicit lifecycle management.
