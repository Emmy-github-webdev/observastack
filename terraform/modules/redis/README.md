# ObservaStack 6.8 — Redis Module

Private Redis OSS cache/data tier using Amazon ElastiCache.

## Includes
- Private cache subnet group
- Dedicated Redis security group
- Multi-AZ and automatic failover
- Customer-managed KMS encryption at rest
- TLS/transit encryption
- Optional Redis AUTH token
- Snapshot retention
- Maintenance/snapshot windows
- CloudWatch engine and slow logs
- Environment-aware tagging and retention

## Security
Redis is private and accepts traffic only from explicitly approved security
groups. Do not expose port 6379 through a VPC-wide CIDR rule.

Transit encryption should remain enabled. If an AUTH token is used, pass it
through a secure mechanism; it is marked sensitive in Terraform but still
becomes part of Terraform state because ElastiCache requires the value.

The KMS key must be the environment-specific ObservaStack key, not the shared
ECR artifact key.

## Baseline sizing
- dev: cache.t4g.micro, 2 nodes, 7-day snapshots
- staging: cache.t4g.small, 2 nodes, 14-day snapshots
- production: cache.r7g.large, 2 nodes, 35-day snapshots

Verify engine/version and instance-class availability in the target AWS region
before applying.

## Validation
Run terraform fmt, init, validate, plan and repository security scanning
before merge.
