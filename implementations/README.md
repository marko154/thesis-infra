# Implementations

Layouts for the same reference scenario. See [methodology/approach-definitions.md](../../methodology/approach-definitions.md).

| Directory | Tool | State layout | Status |
| --- | --- | --- | --- |
| `terraform-workspaces/` | Terraform | One root, workspace per deployment unit | core comparison |
| `terragrunt/` | Terragrunt + Terraform | One state per module stack per unit | core comparison |
| `opentofu/` | OpenTofu | One root; state key from early-evaluated variables | core comparison |
| `terraform-stacks/` | Terraform Stacks (HCP for plan) | One state per Stack deployment | exploratory / proposed 4th |

Shared modules: [`../../modules/`](../../modules/)

Terraform Stacks cannot run a local deployment plan; see that directory’s README and `docs/archive/ANSWER.md` §(d).
