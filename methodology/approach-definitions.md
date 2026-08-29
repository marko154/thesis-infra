# Approach definitions

How the three compared implementations differ. **Only organization and state layout vary**; shared modules and target resources stay the same.

## Shared constraints

- Same modules under `modules/`
- Same deployment units and parameter values from [reference-scenario.md](reference-scenario.md)
- Idiomatic usage of each tool (no artificial handicaps)
- Plan-only evaluation path (`init`, `validate`, `plan`)

## 1. Terraform workspaces (`implementations/terraform-workspaces`)

**Organization:** Single root module tree. Environment and region are selected at plan time.

| Aspect | Choice |
| --- | --- |
| State isolation | One backend; **workspace per deployment unit** (`dev-eu-central-1`, …) |
| Config selection | `-var-file=vars/<unit>.tfvars` + workspace name encodes unit |
| Module wiring | Root `main.tf` calls all four shared modules |
| DRY mechanism | Shared `locals` defaults + per-unit tfvars overrides |

**Rationale:** Workspaces primarily solve state partitioning within one root. Configuration duplication lives in var-files unless extracted to shared locals.

## 2. Terragrunt (`implementations/terragrunt`)

**Organization:** Directory per module per deployment unit; DRY via root `terragrunt.hcl` and `_envcommon` fragments.

| Aspect | Choice |
| --- | --- |
| State isolation | **Separate state file per stack** (network, edge, application, database, monitoring × unit) |
| Config selection | `inputs` blocks in leaf `terragrunt.hcl`; env/region from directory path |
| Module wiring | Each stack is a thin wrapper pointing at `modules/<name>` |
| DRY mechanism | `include` root config, `_envcommon/*.hcl`, `dependency` blocks between stacks |

**Rationale:** Terragrunt adds orchestration, remote-state wiring, and cross-stack dependencies on top of Terraform/OpenTofu.

## 3. OpenTofu (`implementations/opentofu`)

**Organization:** Separate root per deployment unit under `environments/<env>/<region>/`. No Terragrunt.

| Aspect | Choice |
| --- | --- |
| State isolation | **One state per deployment unit** (all four modules in one root) |
| Config selection | `locals` with early-evaluated maps keyed by `environment` and `region`; minimal tfvars |
| Module wiring | Unit `main.tf` calls all four shared modules |
| DRY mechanism | Shared `config/locals.tf` included via symlink or copy; env-specific values resolved in locals before module calls |

**Rationale:** Demonstrates OpenTofu-native configuration without Terragrunt—early variable evaluation and explicit per-unit roots instead of workspaces.

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
| State files per unit | 1 (workspace) | 4 (per module stack) | 1 (per unit root) |
| Root directories per unit | 1 shared | 4 stacks | 1 dedicated |
| Extra tooling | Terraform only | Terragrunt + Terraform/OpenTofu | OpenTofu only |
| Cross-module dependencies | In-root references | `dependency` blocks | In-root references |

## Fairness checklist

Before measuring:

- [ ] All units defined in [reference-scenario.md](reference-scenario.md) exist in each implementation
- [ ] `plan` produces equivalent resource counts per unit (manual spot-check)
- [ ] Tool versions documented in root README
- [ ] Counting rules in [counting-rules.md](counting-rules.md) applied uniformly
