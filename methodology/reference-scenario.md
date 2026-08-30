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

1. **network** — VPC, two public and two private subnets, internet gateway, NAT egress for private subnets, an S3 gateway endpoint, EKS load-balancer subnet tags, node and cluster security groups
2. **edge** — S3 media bucket with versioning and lifecycle rules + Route53 for all units; CloudFront CDN and its cache policy only in `prod` (`enable_cdn`)
3. **application** — EKS cluster + managed node group (replicas, instance size, app version), the four managed add-ons, and a Pod Identity role granting the application access to the media bucket
4. **database** — three RDS PostgreSQL instances (users, metadata, favorites), storage encrypted with a customer-managed KMS key, a shared parameter group, security group allowing PostgreSQL only from the EKS cluster security group
5. **monitoring** — CloudWatch log group owned by the module, SNS alarm topic, and three alarms per database instance (`CPUUtilization`, `FreeStorageSpace`, `DatabaseConnections`)

### Module dependency graph

Six edges, which every approach has to express through its own wiring mechanism:

| From        | To          | Value passed                                        |
| ----------- | ----------- | --------------------------------------------------- |
| network     | application | private subnet ids                                   |
| network     | database    | private subnet ids, VPC id                           |
| edge        | application | media bucket ARN, for the Pod Identity role's policy |
| application | database    | EKS cluster security group id                        |
| application | monitoring  | cluster name                                         |
| database    | monitoring  | RDS instance identifiers                             |

### Egress

Non-prod runs a single NAT gateway shared by both private subnets. `prod` runs one per
availability zone, so a zone failure cannot strand egress for the surviving zone. This is the one
place where prod differs from non-prod structurally rather than only in sizing, and it is driven
by the same `high_availability` flag that sets RDS Multi-AZ.

An S3 gateway endpoint keeps private-subnet S3 traffic — the application writing media — off the
NAT gateway, which bills per gigabyte processed. Interface endpoints are deliberately not used:
with a NAT gateway present they would be redundant.

### Resource counts

| Unit type | network | edge | application | database | monitoring | Total |
| --------- | ------: | ---: | ----------: | -------: | ---------: | ----: |
| non-prod  |      23 |    6 |          16 |       10 |         12 |    67 |
| prod      |      27 |   11 |          16 |       10 |         12 |    76 |

Four units give 286 resources in total. For the single-state approaches (workspaces, OpenTofu,
Stacks) the largest single state is one whole unit, so 76. Terragrunt splits a unit across five
states, so its largest single state is the prod network module, 27.

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
