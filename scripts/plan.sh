#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/plan.sh <deployment-unit>
# Example: ./scripts/plan.sh dev-eu-central-1

UNIT="${1:-dev-eu-central-1}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$UNIT" in
  dev-eu-central-1)
  terraform -chdir="$ROOT/implementations/terraform-workspaces" workspace select dev-eu-central-1
  terraform -chdir="$ROOT/implementations/terraform-workspaces" plan -var-file=vars/dev-eu-central-1.tfvars
  ;;
  *)
  echo "Unsupported unit: $UNIT" >&2
  exit 1
  ;;
esac
