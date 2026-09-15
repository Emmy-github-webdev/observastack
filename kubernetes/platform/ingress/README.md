# Ingress examples

These are examples/contracts, not live production application routing.

Before enabling one:
1. Confirm the Service exists.
2. Confirm the health endpoint.
3. Confirm public vs internal exposure.
4. Confirm security-group/CIDR requirements.
5. Confirm ACM certificate.
6. Review the resulting ALB and target groups.

Do not commit real certificate ARNs as application defaults unless they are intentionally environment-specific configuration.
