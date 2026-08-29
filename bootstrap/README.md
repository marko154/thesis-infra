# Bootstrap — remote state bucket

Creates the single S3 bucket the three OSS approaches use for remote
state. This root is **not** one of the four comparison layouts. Its
state is local, labelled bootstrap, and excluded from approach
authored-line totals and from BR1.

Apply this once, before `init` on workspaces, OpenTofu, or Terragrunt:

```bash
cd bootstrap
terraform init
terraform apply
```

The bucket name is `thesis-tfstate-<account_id>` in `eu-central-1`.
That same literal is in each OSS backend block (Terraform cannot
interpolate a backend). Terraform Stacks keep HCP-managed state and
do not use this bucket.

No DynamoDB table. Locking is S3 native (`use_lockfile`) on the
approach backends.
