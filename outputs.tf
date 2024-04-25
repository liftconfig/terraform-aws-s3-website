# --- Outputs for production website ---

output "website_cloudfront_arn" {
  description = "Production website Cloudfront distribution ARN"
  value       = aws_cloudfront_distribution.website.arn
}

output "website_cloudfront_id" {
  description = "Production website Cloudfront distribution ID"
  value       = aws_cloudfront_distribution.website.id
}

output "website_cloudfront_url" {
  description = "Production website Cloudfront distribution URL"
  value       = "https://${aws_cloudfront_distribution.website.domain_name}"
}

output "website_s3_arn" {
  description = "Production website S3 bucket ARN"
  value       = aws_s3_bucket.website.arn
}

output "website_s3_bucket_name" {
  description = "Production website S3 bucket name"
  value       = aws_s3_bucket.website.bucket
}

output "website_url" {
  description = "Production website URL"
  value       = "https://${var.website_domain}"
}


# --- Outputs for test website ---

output "website_test_s3_arn" {
  description = "Test website S3 bucket ARN"
  value       = aws_s3_bucket.website_test.arn
}

output "website_test_s3_bucket_name" {
  description = "Test website S3 bucket name"
  value       = aws_s3_bucket.website_test.bucket
}

output "website_test_s3_endpoint" {
  description = "Test website S3 bucket endpoint"
  value       = "http://${aws_s3_bucket_website_configuration.website_test.website_endpoint}"
}

output "website_test_url" {
  description = "Test website URL"
  value       = "http://test.${var.website_domain}"
}