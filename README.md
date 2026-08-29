# thesis-infra

Infrastructure-as-Code comparison harness for a diploma thesis on multi-environment configuration organization.

This repository implements a **reference scenario** in three idiomatic layouts (Terraform workspaces, Terragrunt, OpenTofu) and provides the scaffolding for reproducible measurements. It is **not** the LaTeX thesis repo and **not** a full application deployment.

## Scope

- **In scope:** shared modules, three comparable implementations, methodology docs, experiment placeholders, measurement script stubs
- **Out of scope:** `apply` in the thesis path, EKS, Argo CD, Vault, SoundScape microservices

## Reference scenario

| Deployment unit | Environment | Region |
| --- | --- | --- |
| `dev/eu-central-1` | dev | eu-central-1 |
| `stage/eu-central-1` | stage | eu-central-1 |
| `prod/eu-central-1` | prod | eu-central-1 |
| `prod/us-east-1` | prod | us-east-1 |

Each unit composes five shared modules: `network`, `edge`, `application`, `database`, `monitoring`.

Core comparison approaches: Terraform workspaces, Terragrunt, OpenTofu. An exploratory **Terraform Stacks** layout lives under `implementations/terraform-stacks/` (HCP required for deployment plans).

See [methodology/reference-scenario.md](methodology/reference-scenario.md) for parameter values and [methodology/approach-definitions.md](methodology/approach-definitions.md) for how the three approaches differ.

## Repository layout

```text
methodology/       Metrics, counting rules, change catalog, scenario definition
modules/           Shared AWS modules used by all implementations
implementations/   terraform-workspaces | terragrunt | opentofu
experiments/       Standardized change branches/commits (future)
scripts/           validate, plan wrappers, measurement (future)
results/           Raw outputs and generated reports
docs/archive/      Historical context (SoundScape assignment, planning notes)
```

## Tools

CLI versions are pinned in [`mise.toml`](mise.toml). That is the thesis method — not asdf, tfenv, or tgenv. `required_version` in `.tf` files stays as a compatibility floor; mise is the exact binary.

```bash
# https://mise.jdx.dev/getting-started.html
curl https://mise.run | sh
eval "$(mise activate zsh)"   # or bash / fish; see mise docs
mise trust
mise install
```

| Tool | Role | Pin |
| --- | --- | --- |
| Terraform | workspaces, Terragrunt, Stacks (`terraform`) | 1.15.9 |
| OpenTofu | `implementations/opentofu` (`tofu`) | 1.12.6 |
| Terragrunt | `implementations/terragrunt` | 1.1.3 |
| AWS CLI / credentials | `plan` only | — |

## Plan-only workflow

The thesis evaluation path uses **`terraform plan` / `tofu plan`** against AWS. No `apply` is required.

```bash
# Terraform workspaces (example: dev)
cd implementations/terraform-workspaces
terraform init
terraform workspace select dev-eu-central-1 || terraform workspace new dev-eu-central-1
terraform plan -var-file=vars/dev-eu-central-1.tfvars

# OpenTofu (example: dev)
cd implementations/opentofu/environments/dev/eu-central-1
tofu init
tofu plan

# Terragrunt (example: dev network stack)
cd implementations/terragrunt/dev/eu-central-1/network
terragrunt init
terragrunt plan
```

AWS credentials must be configured locally. State uses **local backends** in this scaffold; remote backends can be added later without changing module interfaces.

## Next steps

1. Flesh out all four deployment units in all three implementations
2. Automate the change catalog under `experiments/`
3. Implement measurement scripts under `scripts/`
