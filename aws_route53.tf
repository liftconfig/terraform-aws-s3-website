# --- A/AAAA records for production and test websites ---

locals {
  domain_records = {
    website_domain_v4 = {
      name = var.website_domain
      type = "A"
    }
    website_domain_v6 = {
      name = var.website_domain
      type = "AAAA"
    }
    website_domain_www_v4 = {
      name = "www.${var.website_domain}"
      type = "A"
    }
    website_domain_www_v6 = {
      name = "www.${var.website_domain}"
      type = "AAAA"
    }
  }
  domain_records_test = {
    website_domain_v4 = {
      name = "test.${var.website_domain}"
      type = "A"
    }
    website_domain_v6 = {
      name = "test.${var.website_domain}"
      type = "AAAA"
    }
    website_domain_www_v4 = {
      name = "www.test.${var.website_domain}"
      type = "A"
    }
    website_domain_www_v6 = {
      name = "www.test.${var.website_domain}"
      type = "AAAA"
    }
  }
}

data "aws_route53_zone" "website" {
  name = aws_route53domains_registered_domain.website.domain_name
}
resource "aws_route53domains_registered_domain" "website" {
  domain_name = var.website_domain
  auto_renew  = true

  tags = var.website_tags
}

resource "aws_route53_record" "website" {
  for_each = local.domain_records

  zone_id = data.aws_route53_zone.website.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "website_test" {
  for_each = local.domain_records_test

  zone_id = data.aws_route53_zone.website.zone_id
  name    = each.value.name
  type    = each.value.type

  alias {
    name                   = aws_s3_bucket_website_configuration.website_test.website_domain
    zone_id                = aws_s3_bucket.website_test.hosted_zone_id
    evaluate_target_health = false
  }
}


# --- CNAME records for certificate validation ---

resource "aws_route53_record" "acm_validation" {
  for_each = { for domain in aws_acm_certificate.website.domain_validation_options : domain.domain_name => domain }

  name    = each.value.resource_record_name
  records = [each.value.resource_record_value]
  ttl     = 300
  type    = each.value.resource_record_type
  zone_id = data.aws_route53_zone.website.zone_id
}