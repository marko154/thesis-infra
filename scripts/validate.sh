#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> terraform-workspaces"
terraform -chdir="$ROOT/implementations/terraform-workspaces" fmt -check -recursive
terraform -chdir="$ROOT/implementations/terraform-workspaces" validate

echo "==> opentofu (dev)"
tofu -chdir="$ROOT/implementations/opentofu/environments/dev/eu-central-1" fmt -check -recursive
tofu -chdir="$ROOT/implementations/opentofu/environments/dev/eu-central-1" validate

echo "validate.sh: not yet wired for terragrunt or all deployment units"
