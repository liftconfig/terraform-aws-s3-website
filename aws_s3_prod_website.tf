# --- S3 bucket for production website files ---

resource "aws_s3_bucket" "website" {
  bucket        = var.website_domain
  force_destroy = false

  tags = var.website_tags
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "PolicyForCloudFrontPrivateContent",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipal",
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.website.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${aws_cloudfront_distribution.website.arn}"
          }
        }
      }
    ]
    }
  )
}


# --- S3 bucket for cloudfront logs ---

locals {
  aws_log_delivery_id = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
}

data "aws_canonical_user_id" "current" {}

resource "aws_s3_bucket" "website_log" {
  bucket        = "${var.website_domain}-log"
  force_destroy = false

  tags = var.website_tags
}

resource "aws_s3_bucket_ownership_controls" "website_log" {
  bucket = aws_s3_bucket.website_log.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "website_log" {
  depends_on = [aws_s3_bucket_ownership_controls.website_log]

  bucket = aws_s3_bucket.website_log.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    grant {
      grantee {
        id   = local.aws_log_delivery_id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
}