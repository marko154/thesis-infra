# Infrastructure architecture

Reference AWS layout for one deployment unit. Auth0 and Stripe are external and not provisioned by this repo.

Source of truth for parameters: [`../methodology/reference-scenario.md`](../methodology/reference-scenario.md).

## Per-unit AWS architecture

CloudFront is **prod-only**. Dev/stage keep S3 + Route53; clients talk to EKS and S3 without a CDN hop.

```mermaid
flowchart TB
  users[Clients]

  subgraph edge [edge module]
    r53[Route53 hosted zone]
    cf[CloudFront CDN prod only]
    s3[S3 media bucket]
  end

  subgraph network [network module]
    vpc[VPC]
    pub[Public subnets]
    priv[Private subnets]
    vpc --> pub
    vpc --> priv
  end

  subgraph app [application module]
    eks[EKS cluster]
    ng[Managed node group]
    eks --> ng
  end

  subgraph data [database module]
    rdsUsers[RDS users]
    rdsMeta[RDS metadata]
    rdsFav[RDS favorites]
  end

  subgraph mon [monitoring module]
    cwlogs[CloudWatch log group]
    alarm[CPU alarm ContainerInsights]
  end

  users -->|DNS| r53
  r53 -.->|cdn CNAME prod only| cf
  cf -.->|OAC GetObject| s3
  users -->|API| eks
  users -->|media direct in non-prod| s3
  ng --> priv
  rdsUsers --> priv
  rdsMeta --> priv
  rdsFav --> priv
  eks --> cwlogs
  eks --> alarm
```

## Module dependency graph

```mermaid
flowchart LR
  network --> application
  network --> database
  application --> monitoring
  edge
```

- **network** — VPC + public/private subnets (CIDR per env/region)
- **edge** — S3 + Route53 always; CloudFront + `cdn.` record only when `enable_cdn = true` (prod)
- **application** — EKS in private subnets
- **database** — three RDS instances (users, metadata, favorites) in private subnets
- **monitoring** — watches the EKS cluster

## Deployment units

```mermaid
flowchart TB
  subgraph eu_central [eu-central-1]
    dev[dev]
    stage[stage]
    prod_c[prod]
  end

  subgraph us_east [us-east-1]
    prod_e[prod]
  end
```

| Unit | DNS zone | CDN |
| --- | --- | --- |
| `dev/eu-central-1` | `dev.eu-central-1.thesis-app.example` | off |
| `stage/eu-central-1` | `stage.eu-central-1.thesis-app.example` | off |
| `prod/eu-central-1` | `prod.eu-central-1.thesis-app.example` | `cdn.prod.eu-central-1.thesis-app.example` |
| `prod/us-east-1` | `prod.us-east-1.thesis-app.example` | `cdn.prod.us-east-1.thesis-app.example` |

## Application architecture vs this repo

[`architecture-diagram.png`](architecture-diagram.png) is the **application** view (Remix frontend, upload/metadata/favorites/users services).

This document is the **infrastructure** view: how those workloads sit on AWS (EKS, RDS, S3/CloudFront/Route53). Microservices run on the EKS node group; Auth0/Stripe stay SaaS.
