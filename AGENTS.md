Before work, read `../CONTEXT.md` and the active ticket under `../.scratch/`.

Implementation diffs stay in this repo. Methodology source of truth: `methodology/`.

CLI versions come from `mise.toml` at this repo root. Install [mise](https://mise.jdx.dev/getting-started.html), activate it in the shell, then `mise trust && mise install`. Do not use asdf, tfenv, or tgenv for this harness. `required_version` in `.tf` files is a compatibility floor; mise is the exact binary. The AWS provider is pinned `~> 6.0` in every module and every approach (`versions.tf` / Stacks `required_providers`); lock files record the resolved 6.x. Terragrunt has no separate pin: units consume the module `versions.tf`.
