# Terraform Stacks (exploratory)

Sketch of the same reference scenario as a HashiCorp **Terraform Stack**:

- `*.tfcomponent.hcl` — shared component graph (network, edge, application, database, monitoring)
- `*.tfdeploy.hcl` — one `deployment` block per thesis unit (4 total)

## Local vs HCP

| Action | Where |
| --- | --- |
| `terraform stacks init` / `validate` / `fmt` | Local CLI (Terraform ≥ 1.13) |
| Deployment plan / apply | **HCP Terraform only** (no local plan) |

AWS provider constraint: `~> 6.0` (same major as the other approaches; see repo `README.md`).

This lane is included to evaluate Stacks against the same scenario. Metric caveats (what is reproducible offline vs needs HCP) are discussed in `docs/archive/ANSWER.md`.

## Quick start (local structure check)

```bash
cd implementations/terraform-stacks
terraform stacks init
terraform stacks validate
```

Creating a Stack and uploading configuration for remote plans:

```bash
terraform stacks create \
  -organization-name <ORG> \
  -project-name <PROJECT> \
  -stack-name thesis-ref

terraform stacks configuration upload \
  -organization-name <ORG> \
  -project-name <PROJECT> \
  -stack-name thesis-ref
```

Provider auth for real HCP plans is not wired yet (OIDC `identity_token` or varset). Add when you run a remote plan.
