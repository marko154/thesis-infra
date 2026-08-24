# thesis-infra

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
