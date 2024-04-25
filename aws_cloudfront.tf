# --- Cloudfront distribution for production website ---

locals {
  cloudfront_prefix = split(".", var.website_domain)[0]
}

resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = var.cloudfront_price_class
  default_root_object = var.cloudfront_root_object
  aliases = [
    var.website_domain,
    "www.${var.website_domain}",
  ]

  origin {
    domain_name              = aws_s3_bucket.website.bucket_domain_name
    origin_id                = aws_s3_bucket.website.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
    connection_attempts      = 3
    connection_timeout       = 10
  }

  default_cache_behavior {
    cache_policy_id        = aws_cloudfront_cache_policy.website.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    target_origin_id       = aws_s3_bucket.website.bucket_domain_name

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.www_redirect.arn
    }
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/${var.cloudfront_error_page}"
    error_caching_min_ttl = 10
  }

  logging_config {
    bucket          = aws_s3_bucket.website_log.bucket_domain_name
    include_cookies = false
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  tags = var.website_tags

  depends_on = [aws_s3_bucket_acl.website_log]
}

resource "aws_cloudfront_origin_access_control" "website" {
  name                              = local.cloudfront_prefix
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "website" {
  name        = local.cloudfront_prefix
  default_ttl = var.cloudfront_default_ttl
  min_ttl     = 1
  max_ttl     = 604800

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

#  A CloudFront function to:
#  1) redirect www-prefixed URLs to the apex domain, enhancing user experience and consolidating domain authority.
#  2) Rewrite URL to append index.html to the URI for statically generated websites

resource "aws_cloudfront_function" "www_redirect" {
  name    = "${local.cloudfront_prefix}-www-redirect"
  runtime = "cloudfront-js-2.0"
  code    = file("${path.module}/cloudfront-function.js")
  publish = true
}