# Applications

Application definitions belong here.

Recommended naming:

```text
<service>-<environment>
```

Examples:

```text
user-service-dev
user-service-staging
user-service-production
```

Use AppProjects to constrain where applications can deploy.

Do not place Terraform-managed AWS resources in these applications.
