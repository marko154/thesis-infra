module "naming" {
  source = "../naming"

  environment = var.environment
  region      = var.region
}

locals {
  name_prefix = module.naming.prefix

  instance_class_map = {
    small  = "db.t3.micro"
    medium = "db.t3.small"
    large  = "db.t3.medium"
  }

  # Matches application architecture: users, metadata, favorites services each own a DB.
  databases = toset(["users", "metadata", "favorites"])
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.name_prefix}-db"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-db-subnet-group"
  })
}

resource "aws_security_group" "this" {
  name        = "${local.name_prefix}-rds"
  description = "PostgreSQL from the compute tier only"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-rds-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "postgres_from_compute" {
  security_group_id            = aws_security_group.this.id
  referenced_security_group_id = var.allowed_security_group_id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_db_instance" "this" {
  for_each = local.databases

  identifier                  = "${local.name_prefix}-${each.key}"
  engine                      = "postgres"
  engine_version              = "15"
  instance_class              = lookup(local.instance_class_map, var.instance_size, local.instance_class_map.small)
  allocated_storage           = var.storage_gb
  storage_encrypted           = true
  db_name                     = replace(each.key, "-", "_")
  username                    = "thesis_app"
  manage_master_user_password = true
  skip_final_snapshot         = true
  multi_az                    = var.high_availability
  backup_retention_period     = var.backup_retention_days
  db_subnet_group_name        = aws_db_subnet_group.this.name
  vpc_security_group_ids      = [aws_security_group.this.id]
  publicly_accessible         = false

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-${each.key}"
    Service = each.key
  })
}
