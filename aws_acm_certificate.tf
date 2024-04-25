# --- Certificate for cloudfront distribution ---

resource "aws_acm_certificate" "website" {
  provider                  = aws.us-east-1
  domain_name               = var.website_domain
  subject_alternative_names = ["www.${var.website_domain}"]
  validation_method         = "DNS"

  tags = var.website_tags

  lifecycle {
    create_before_destroy = true
  }
}