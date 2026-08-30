# OpenTofu — early variable evaluation

One root. Four `vars/<unit>.tfvars` files. The S3 state key is derived
from `var.environment` and `var.region` (OpenTofu 1.8+). Terraform
rejects that interpolation (`Variables not allowed`).

Switching unit requires `-reconfigure` because the backend key changes:

```bash
tofu init -reconfigure -var-file=vars/dev-eu-central-1.tfvars
tofu plan     -var-file=vars/dev-eu-central-1.tfvars
```

State keys stay `opentofu/<env>/<region>/terraform.tfstate` in the
bootstrap bucket (`eu-central-1`). The bucket name and backend region
are literals: there is one bucket, not one per workload region.
