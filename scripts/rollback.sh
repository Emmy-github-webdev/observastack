#!/usr/bin/env bash
set -euo pipefail
APP="${1:-}"
HISTORY_ID="${2:-}"

[[ -n "$APP" ]] || { echo "Usage: $0 <application> [history-id]" >&2; exit 2; }
[[ "$APP" =~ ^(user-service|product-service|order-service|payment-service)-(dev|staging|production)$ ]] || { echo "Invalid application name" >&2; exit 2; }

argocd app history "$APP"
if [[ -z "$HISTORY_ID" ]]; then
  read -r -p "Enter approved history ID to rollback: " HISTORY_ID
fi
[[ "$HISTORY_ID" =~ ^[0-9]+$ ]] || { echo "History ID must be numeric" >&2; exit 2; }

echo "Rolling back $APP to history ID $HISTORY_ID"
argocd app rollback "$APP" "$HISTORY_ID"
argocd app wait "$APP" --health --sync --timeout 600
