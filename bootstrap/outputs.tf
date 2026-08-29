output "bucket_name" {
  description = "S3 bucket the OSS approaches use for remote state."
  value       = aws_s3_bucket.state.bucket
}

output "bucket_region" {
  description = "Region of the remote state bucket."
  value       = "eu-central-1"
}
