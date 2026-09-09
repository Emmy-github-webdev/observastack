## Module structure

```
terraform/modules/rds/
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── locals.tf
├── README.md
└── INTEGRATION.md
```

## Environment Sizing

```
| Environment | Instance        | Storage |     Max |  Backup |
| ----------- | --------------- | ------: | ------: | ------: |
| dev         | `db.t4g.micro`  |  20 GiB | 100 GiB |  7 days |
| staging     | `db.t4g.medium` |  50 GiB | 200 GiB | 14 days |
| production  | `db.r7g.large`  | 100 GiB | 500 GiB | 35 days |

```
The RDS module does not grant database access to the entire VPC or EKS cluster.

```
Application / Workload SG
          │
          │ TCP/5432
          ▼
   ObservaStack RDS SG
          │
          ▼
   Private PostgreSQL
```

We'll provide a dedicated workload/application security group when composing the EKS/platform layer rather than using the EKS cluster SG as a broad trust boundary.

Also, the RDS KMS key is environment-specific. The shared KMS key we're creating for ECR must not be reused for RDS. AWS's guidance specifically recommends dedicated customer-managed keys for RDS use