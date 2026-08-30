module "naming" {
  source = "../naming"

  environment = var.environment
  region      = var.region
}

locals {
  name_prefix = module.naming.prefix
}

data "aws_caller_identity" "current" {}

# Object storage for media assets (all environments). Account id is required
# because S3 names are global; four predictable thesis-*-media names collide.
resource "aws_s3_bucket" "media" {
  bucket = "${local.name_prefix}-media-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-media"
  })
}

resource "aws_s3_bucket_public_access_block" "media" {
  bucket = aws_s3_bucket.media.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "media" {
  bucket = aws_s3_bucket.media.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Versioning without expiry grows forever, and failed multipart uploads are
# billed until they are aborted.
resource "aws_s3_bucket_lifecycle_configuration" "media" {
  bucket = aws_s3_bucket.media.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  depends_on = [aws_s3_bucket_versioning.media]
}

# CDN only in prod (enable_cdn = true)
resource "aws_cloudfront_origin_access_control" "media" {
  count = var.enable_cdn ? 1 : 0

  name                              = "${local.name_prefix}-media-oac"
  description                       = "OAC for ${local.name_prefix} media bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Cache policies replace the legacy forwarded_values block, which AWS has
# deprecated for new distributions.
resource "aws_cloudfront_cache_policy" "media" {
  count = var.enable_cdn ? 1 : 0

  name        = "${local.name_prefix}-media"
  comment     = "Cache key for ${local.name_prefix} media objects"
  default_ttl = 86400
  min_ttl     = 1
  max_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "media" {
  count = var.enable_cdn ? 1 : 0

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${local.name_prefix} media CDN"
  default_root_object = "index.html"
  price_class         = "PriceClass_100"

  origin {
    domain_name              = aws_s3_bucket.media.bucket_regional_domain_name
    origin_id                = "s3-media"
    origin_access_control_id = aws_cloudfront_origin_access_control.media[0].id
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "s3-media"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    cache_policy_id        = aws_cloudfront_cache_policy.media[0].id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-cdn"
  })
}

data "aws_iam_policy_document" "media_oac" {
  count = var.enable_cdn ? 1 : 0

  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.media.arn}/*"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.media[0].arn]
    }
  }
}

resource "aws_s3_bucket_policy" "media" {
  count = var.enable_cdn ? 1 : 0

  bucket = aws_s3_bucket.media.id
  policy = data.aws_iam_policy_document.media_oac[0].json
}

# DNS for this environment/region unit (all environments)
resource "aws_route53_zone" "this" {
  name = var.domain_name

  tags = merge(var.tags, {
    Name = "${local.name_prefix}-zone"
  })
}

resource "aws_route53_record" "cdn" {
  count = var.enable_cdn ? 1 : 0

  zone_id = aws_route53_zone.this.zone_id
  name    = "cdn.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_cloudfront_distribution.media[0].domain_name]
}
