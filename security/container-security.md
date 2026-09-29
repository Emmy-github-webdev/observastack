# Container Security

All four services:

- use a slim Python runtime
- run as UID 10001
- do not require privileged mode
- do not require host networking
- do not contain credentials
- expose only TCP/8080
- are compatible with Kubernetes `runAsNonRoot`
- are intended for read-only root filesystems

Future service manifests should inherit the Pod Security and NetworkPolicy controls established in Step 7.
