output "db_identifiers" {
  description = "Map of service name → RDS identifier (users, metadata, favorites)."
  value       = { for name, db in aws_db_instance.this : name => db.identifier }
}

output "db_endpoints" {
  description = "Map of service name → RDS endpoint."
  value       = { for name, db in aws_db_instance.this : name => db.endpoint }
}

output "db_names" {
  description = "Logical database names per service."
  value       = { for name, db in aws_db_instance.this : name => db.db_name }
}

output "kms_key_arn" {
  description = "Customer-managed key encrypting RDS storage."
  value       = aws_kms_key.rds.arn
}
