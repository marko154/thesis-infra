output "media_bucket_id" {
  value = aws_s3_bucket.media.id
}

output "media_bucket_arn" {
  value = aws_s3_bucket.media.arn
}

output "cloudfront_distribution_id" {
  value = try(aws_cloudfront_distribution.media[0].id, null)
}

output "cloudfront_domain_name" {
  value = try(aws_cloudfront_distribution.media[0].domain_name, null)
}

output "route53_zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "route53_name_servers" {
  value = aws_route53_zone.this.name_servers
}

output "domain_name" {
  value = var.domain_name
}

output "enable_cdn" {
  value = var.enable_cdn
}
