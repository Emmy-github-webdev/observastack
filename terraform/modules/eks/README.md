## provision

```
EKS
│
├── EKS Control Plane
│   ├── Kubernetes API
│   ├── private endpoint
│   ├── access entries
│   ├── control-plane logging
│   └── encryption
│
├── Managed Node Groups
│   ├── private subnets
│   ├── on-demand nodes
│   ├── capacity/scaling
│   └── encrypted EBS
│
├── Cluster Security
│   ├── cluster security group
│   ├── node security group
│   └── restricted communication
│
└── EKS Add-ons
    ├── VPC CNI
    ├── CoreDNS
    ├── kube-proxy
    └── EBS CSI
```

Architecture

```
                         Internet
                            │
                            ▼
                    AWS Load Balancer
                            │
                            ▼
                  ┌─────────────────────┐
                  │        EKS          │
                  │                     │
                  │  Control Plane      │
                  │       │             │
                  │       ▼             │
                  │  Managed Nodes      │
                  │                     │
                  │  private subnets    │
                  └─────────┬───────────┘
                            │
          ┌─────────────────┼─────────────────┐
          ▼                 ▼                 ▼
      Services         Observability       Platform
          │                 │                 │
          ▼                 ▼                 ▼
       Argo CD          Prometheus       External Secrets
                        Grafana           Cert Manager
                        Loki              AWS LB Controller
                        Tempo
```