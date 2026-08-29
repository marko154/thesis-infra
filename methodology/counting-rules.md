# Counting rules

Rules for reproducible measurement. Apply identically to all three implementations.

## File inclusion

**Count:**

- `*.tf`, `*.tfvars`, `*.hcl` under `implementations/` and `modules/`
- Terragrunt `terragrunt.hcl` and `_envcommon` fragments
- Symlinked shared config if present

**Exclude:**

- `.terraform/`, `.terragrunt-cache/`
- `*.tfstate`, `*.tfstate.*`, `*.tfplan`
- Lock files (`.terraform.lock.hcl`) — report separately, do not count as authored config
- `results/`, `experiments/` output artifacts
- `scripts/` (measurement tooling, not IaC config)
- `methodology/`, `docs/`, `README.md`

## Line counting

1. Strip comments (`#`, `//`, `/* */`)
2. Strip blank lines
3. Count remaining lines per file; sum for totals
4. For duplication detection: normalize whitespace; treat identical normalized blocks as duplicates

## Git diff counting (change amplification)

- Baseline: annotated tag `baseline-v1` (or experiment branch parent)
- Compare: single commit or branch tip implementing one catalog change
- Use `git diff --numstat` between baseline and change commit
- Count only files matching inclusion rules above

## Plan operation counting

One `plan` invocation = one operation, even if it plans multiple modules in one root.

For Terragrunt:

- `terragrunt run-all plan` = one operation per stack that runs
- Document whether `run-all` or individual stack plans were used

## State file counting

After `init` + `plan` for all units:

- Count distinct state files on disk
- Record resource count per state (`terraform state list` / equivalent)

## Equivalence verification

Before accepting measurements:

1. Same four modules wired per unit
2. Same input values from [reference-scenario.md](reference-scenario.md)
3. Resource naming convention followed
4. No implementation-specific resources outside the shared module contract

## Generated files

If Terragrunt `generate` blocks emit files:

- Report generated line count separately
- Default: **exclude** from authored-config metrics unless the generate block itself is the change under study
