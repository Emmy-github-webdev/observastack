# Release Flow

## Immutable image principle

Build once from a source commit. Tag with the immutable Git SHA. Resolve and promote the same ECR digest through environments.

Example:

`observastack/user-service:<git-sha>`

becomes:

`observastack/user-service@sha256:<digest>`

The deployment manifest should reference the digest rather than a mutable tag.

## Environment progression

`dev -> staging -> production`

Promotion does not rebuild the image.

## Rollback

Rollback selects a previously approved image digest and updates the GitOps deployment reference. The rollback is observable through Git history and Argo CD history.
