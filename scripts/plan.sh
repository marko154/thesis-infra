#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/plan.sh <deployment-unit>
# Example: ./scripts/plan.sh dev-eu-central-1

UNIT="${1:-dev-eu-central-1}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WS="$ROOT/implementations/terraform-workspaces"

case "$UNIT" in
  dev-eu-central-1 | stage-eu-central-1 | prod-eu-central-1 | prod-us-east-1)
    terraform -chdir="$WS" workspace select "$UNIT"
    terraform -chdir="$WS" plan
    ;;
  *)
    echo "Unsupported unit: $UNIT" >&2
    exit 1
    ;;
esac
