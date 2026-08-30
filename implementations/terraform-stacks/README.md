# Terraform Stacks

Same reference scenario as the other approaches, as a HashiCorp **Terraform Stack**:

- `*.tfcomponent.hcl` — shared component graph (network, edge, application, database, monitoring)
- `*.tfdeploy.hcl` — one `deployment` block per thesis unit (4 total)
- OIDC: `identity_token "aws"` + `assume_role_with_web_identity` (IAM role is a placeholder until HCP is wired)

## Local vs HCP

| Action | Where |
| --- | --- |
| `terraform stacks init` / `validate` / `fmt` | Local CLI after `terraform login` (stacksplugin is signed by HCP) |
| Deployment plan / apply | **HCP Terraform only** (no local plan) |

AWS provider constraint: `~> 6.0` (same major as the other approaches; see repo `README.md`).

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
