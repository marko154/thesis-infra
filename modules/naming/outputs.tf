output "region_short" {
  description = "Short region code used in resource names (euc1, use1)."
  value       = local.region_short[var.region]
}

output "prefix" {
  description = "thesis-{environment}-{region_short}"
  value       = "thesis-${var.environment}-${local.region_short[var.region]}"
}
