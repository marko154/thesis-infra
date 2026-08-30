# Reference scenario

Fixed scenario used for fair comparison across all three IaC organization approaches.

## Deployment units

| Unit ID              | Environment | Region       | Notes                       |
| -------------------- | ----------- | ------------ | --------------------------- |
| `dev-eu-central-1`   | dev         | eu-central-1 | Single-region dev           |
| `stage-eu-central-1` | stage       | eu-central-1 | Single-region staging       |
| `prod-eu-central-1`  | prod        | eu-central-1 | Primary production region   |
| `prod-us-east-1`     | prod        | us-east-1    | Secondary production region |

`dev` and `stage` use one region each. `prod` spans two regions.

## Logical modules

Each deployment unit composes the same five modules:

1. **network** — VPC, public/private subnets, environment- and region-specific CIDR
2. **edge** — S3 media bucket + Route53 for all units; CloudFront CDN only in `prod` (`enable_cdn`)
3. **application** — EKS cluster + managed node group (replicas, instance size, app version)
4. **database** — three RDS PostgreSQL instances (users, metadata, favorites), shared sizing/HA/backup settings
5. **monitoring** — CloudWatch log group for EKS, CPU alarm (Container Insights)

AWS mapping from the reference architecture diagram:

| Diagram concept        | AWS resource |
| ---------------------- | ------------ |
| CDN / Front Door       | CloudFront   |
| Songs / object storage | S3           |
| DNS                    | Route53      |
| Microservices compute  | EKS          |
| Postgres DBs           | RDS          |

Auth0 and Stripe remain external SaaS (not modeled in IaC).

## Environment parameters

| Parameter                    |   dev |  stage |  prod |
| ---------------------------- | ----: | -----: | ----: |
| Application replicas         |     1 |      2 |     4 |
| Application instance size    | small | medium | large |
| Database instance size       | small | medium | large |
| Database storage (GB)        |    20 |     50 |   100 |
| Log retention (days)         |     7 |     30 |    90 |
| High availability (database) |    no |     no |   yes |
| Backup retention (days)      |     1 |      7 |    30 |
| Default app version          | 1.0.0 |  1.0.0 | 1.0.0 |

`prod` parameters apply to both `prod-eu-central-1` and `prod-us-east-1`.

## Regional overrides

| Setting                 | eu-central-1 | us-east-1    |
| ----------------------- | ------------ | ------------ |
| VPC CIDR (dev)          | 10.10.0.0/16 | —            |
| VPC CIDR (stage)        | 10.20.0.0/16 | —            |
| VPC CIDR (prod)         | 10.30.0.0/16 | 10.31.0.0/16 |
| CPU alarm threshold (%) | 80           | 75           |

Region-specific values exist so change experiments can target a single region without touching others.

## Instance size mapping

| Label  | EKS node instance type | RDS instance class |
| ------ | ---------------------- | ------------------ |
| small  | t3.small               | db.t3.micro        |
| medium | t3.medium              | db.t3.small        |
| large  | t3.large               | db.t3.medium       |

## DNS

Each deployment unit gets a Route53 public hosted zone:

`{environment}.{region}.thesis-app.example`

CDN is enabled **only for prod** (`enable_cdn = true`):

`cdn.{environment}.{region}.thesis-app.example` (CNAME → CloudFront)

Examples:

- prod: `cdn.prod.eu-central-1.thesis-app.example`
- non-prod: no CDN record; media stays on S3 without CloudFront

## Resource naming

Resources follow: `thesis-{environment}-{region_short}-{component}`

Short codes live in one shared map (`modules/naming`): `eu-central-1` → `euc1`, `us-east-1` → `use1`. Adding a region is one edit there.

Example: `thesis-prod-use1-eks` (EKS cluster in `prod` / `us-east-1`).

S3 media buckets are globally unique, so they append the AWS account id:

`thesis-{environment}-{region_short}-media-{account_id}`


## Equivalence rules

- All three implementations must produce the same logical resource set per deployment unit
- Input values from this document are authoritative
- Module source code is shared under `modules/`; implementations only differ in organization and state layout
