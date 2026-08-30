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

resource "aws_db_instance" "this" {
  for_each = local.databases

  identifier                  = "${local.name_prefix}-${each.key}"
  engine                      = "postgres"
  engine_version              = "15"
  instance_class              = lookup(local.instance_class_map, var.instance_size, local.instance_class_map.small)
  allocated_storage           = var.storage_gb
  db_name                     = replace(each.key, "-", "_")
  username                    = "thesis_app"
  manage_master_user_password = true
  skip_final_snapshot         = true
  multi_az                    = var.high_availability
  backup_retention_period     = var.backup_retention_days
  db_subnet_group_name        = aws_db_subnet_group.this.name
  publicly_accessible         = false

  tags = merge(var.tags, {
    Name    = "${local.name_prefix}-${each.key}"
    Service = each.key
  })
}
