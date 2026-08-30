# Approach definitions

How the three compared implementations differ. **Only organization and state layout vary**; shared modules and target resources stay the same.

## Shared constraints

- Same modules under `modules/`
- Same deployment units and parameter values from [reference-scenario.md](reference-scenario.md)
- Idiomatic usage of each tool (no artificial handicaps)
- Plan-only evaluation path (`init`, `validate`, `plan`)

## 1. Terraform workspaces (`implementations/terraform-workspaces`)

**Organization:** Single root module tree. The selected workspace *is* the deployment unit. A `locals` map keyed by `terraform.workspace` supplies every per-unit value. There are no var-files: selecting `prod-us-east-1` cannot apply `dev` values.

| Aspect | Choice |
| --- | --- |
| State isolation | One S3 backend; **workspace per deployment unit** (`workspaces/<unit>/terraform.tfstate`) |
| Config selection | `terraform workspace select <unit>` — name is the map key |
| Module wiring | Root `main.tf` calls all five shared modules |
| DRY mechanism | One `units` map in `locals.tf`. A per-unit change is an edit to that map, not a new file |

**Rationale:** Workspaces partition state *and* bind configuration to the same name, so the classic var-file/workspace mismatch cannot happen. That is a CA3 change versus OpenTofu, which still defines units as tfvars because its backend key is interpolated at init.

## 2. Terragrunt (`implementations/terragrunt`)

**Organization:** Directory per module per deployment unit; DRY via root `terragrunt.hcl` and `_envcommon` fragments.

| Aspect | Choice |
| --- | --- |
| State isolation | **Separate S3 key per stack** (`terragrunt/<env>/<region>/<module>/terraform.tfstate`) |
| Config selection | `inputs` blocks in leaf `terragrunt.hcl`; env/region from directory path |
| Module wiring | Each stack is a thin wrapper pointing at `modules/<name>` |
| DRY mechanism | `include` root config, `_envcommon/*.hcl`, `dependency` blocks between stacks |

**Rationale:** Terragrunt adds orchestration, remote-state wiring, and cross-stack dependencies on top of Terraform/OpenTofu.

## 3. OpenTofu (`implementations/opentofu`)

**Organization:** Single root module tree. Environment and region are selected with `-var-file`. The backend key is interpolated from those variables (OpenTofu 1.8+ early evaluation). Terraform rejects the same block (`Variables not allowed`).

| Aspect | Choice |
| --- | --- |
| State isolation | **One S3 key per deployment unit**, derived at init: `opentofu/${var.environment}/${var.region}/terraform.tfstate`. Switch unit with `tofu init -reconfigure -var-file=…` |
| Config selection | `-var-file=vars/<unit>.tfvars` |
| Module wiring | Root `main.tf` calls all five shared modules |
| DRY mechanism | Shared `locals` (tags, domain, CDN flag) + per-unit tfvars. No settings module |

**Rationale:** The one thing OpenTofu can do here that Terraform cannot: put variables in the backend block so a new unit is a new tfvars file, not a copied root and not a workspace.

## 4. Terraform Stacks (`implementations/terraform-stacks`) — proposed / exploratory

**Organization:** Component graph in `*.tfcomponent.hcl`; one `deployment` block per unit in `*.tfdeploy.hcl`.

| Aspect | Choice |
| --- | --- |
| State isolation | **One state per Stack deployment** (HCP-managed) |
| Config selection | Deployment `inputs` in `tfdeploy.hcl` |
| Module wiring | `component` blocks → shared `modules/*` |
| DRY mechanism | Single component config reused across deployments |
| Plan location | **HCP Terraform** (no local deployment plan) |

**Status:** Included as a sketch for mentor discussion. Not yet a peer in the core three-way harness until methodology caveats are agreed. See `docs/archive/ANSWER.md` §(d).

## Comparison dimensions (preview)

| Dimension | Workspaces | Terragrunt | OpenTofu |
| --- | --- | --- | --- |
| State files per unit | 1 (workspace) | 4 (per module stack) | 1 (derived S3 key) |
| Root directories per unit | 1 shared | 4 stacks | 1 shared |
| Extra tooling | Terraform only | Terragrunt + Terraform/OpenTofu | OpenTofu only |
| Cross-module dependencies | In-root references | `dependency` blocks | In-root references |

## Fairness checklist

Before measuring:

- [ ] All units defined in [reference-scenario.md](reference-scenario.md) exist in each implementation
- [ ] `plan` produces equivalent resource counts per unit (manual spot-check)
- [ ] Tool versions documented in root README
- [ ] Counting rules in [counting-rules.md](counting-rules.md) applied uniformly
