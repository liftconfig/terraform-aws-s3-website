# --- S3 bucket for test website files ---

resource "aws_s3_bucket" "website_test" {
  bucket        = "test.${var.website_domain}"
  force_destroy = true

  tags = var.website_test_tags
}

resource "aws_s3_bucket_website_configuration" "website_test" {
  bucket = aws_s3_bucket.website_test.id

  index_document {
    suffix = var.cloudfront_root_object
  }

  error_document {
    key = var.cloudfront_error_page
  }
}

# Bucket restricted to IP whitelist
resource "aws_s3_bucket_policy" "website_test" {
  bucket = aws_s3_bucket.website_test.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "RestrictedReadGetObject",
        Effect    = "Allow",
        Principal = "*"
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.website_test.arn}/*",
        Condition = {
          IpAddress = {
            "AWS:SourceIP" = var.website_test_ip_whitelist
          }
        }
      }
    ]
    }
  )
}


# --- S3 bucket for test website 'www' redirect ---

resource "aws_s3_bucket" "website_test_www" {
  bucket        = "www.test.${var.website_domain}"
  force_destroy = true

  tags = var.website_test_tags
}

resource "aws_s3_bucket_website_configuration" "website_test_www" {
  bucket = aws_s3_bucket.website_test_www.id
  redirect_all_requests_to {
    host_name = "test.${var.website_domain}"
    protocol  = "http"
  }
}