# AWS S3 static website - Terraform module

## Purpose

Provisions the required AWS resources to host and run a statically-generated website. Resources are included for a production and a test version of the website. CloudFront is used to serve the public production website via HTTPS, while S3 built-in static website hosting is used to serve a test website via HTTP privately. The test website uses a bucket policy to restrict access to a list of specified external IPs. This is cheaper than using CloudFront + WAF to whitelist access.

## Prerequisites

A domain and hosted zone registered in route53 matching the domain of the website to be provisioned. The `aws_route53domains_registered_domain` resource and `aws_route53_zone` data resource are used to reference the existing domain and hosted zone

## Resources

### Production website resources

- S3 buckets for the website files and CloudFront logs
- CloudFront distribution with OAC to provide HTTPS access to the website
- CloudFront function to redirect www requests to the bare website URL and append index.html to the URI ([required when using some static website generators](https://github.com/aws-samples/amazon-cloudfront-functions/tree/main/url-rewrite-single-page-apps))
- ACM certificate for the CloudFront distribution
- Route 53 CNAME records for ACM certificate DNS validation
- Route 53 A/AAAA records for the www & bare website URLs

### Test website resources

- S3 bucket with static website hosting enabled for the bare test URL
- S3 bucket with static website hosting enabled to redirect www requests to the first bucket
- Route 53 A/AAAA records for the www & bare test website URLs

## Input variables

### Required input variables

| Input name                  | Type          | Default value | Description                                          |
|:----------------------------|:--------------|:--------------|:-----------------------------------------------------|
| `website_domain`            | string        | N/A           | Website domain name including TLD e.g. mywebsite.com |
| `website_tags`              | map (string)  | N/A           | Tags for the production website resources            |
| `website_test_ip_whitelist` | list (string) | N/A           | IPs allowed to access the test website               |
| `website_test_tags`         | map (string)  | N/A           | Tags for the test website resources                  |

### Optional input variables

| Input name                  | Type   | Default value    | Description                                                                          |
|:----------------------------|:-------|:-----------------|:-------------------------------------------------------------------------------------|
| `cloudfront_default_ttl`    | number | 86400 (24 hours) | Default TTL for pages in CloudFront cache                                            |
| `cloudfront_error_page`     | string | 404.html         | The object that CloudFront serves when a 404 error is returned                       |
| `cloudfront_price_class`    | string | price class 100  | Price class for CloudFront (Options: PriceClass_All, PriceClass_200, PriceClass_100) |
| `cloudfront_root_object`    | string | index.html       | The object that CloudFront serves when the root URL is requested                     |

## Output variables

### Production website outputs

| Output Name              | Description                          |
|:-------------------------|:-------------------------------------|
| `website_cloudfront_arn` | Cloudfront distribution ARN          |
| `website_cloudfront_id`  | Cloudfront distribution ID           |
| `website_cloudfront_url` | Cloudfront distribution URL          |
| `website_s3_arn`         | S3 bucket hosting website files ARN  |
| `website_s3_bucket_name` | S3 bucket hosting website files name |
| `website_url`            | Production website URL               |

### Test website outputs

| Output Name                   | Description                              |
|:------------------------------|:-----------------------------------------|
| `website_test_s3_arn`         | S3 bucket hosting website files ARN      |
| `website_test_s3_bucket_name` | S3 bucket hosting website files name     |
| `website_test_s3_endpoint`    | S3 bucket hosting website files endpoint |
| `website_test_url`            | Test website URL                         |

## Provider configuration

Non-global resources (e.g. S3 buckets) will be provisioned in the region specified in the default AWS provider in the root module. The root module requires a named provider for us-east-1 so that the ACM certificate used by CloudFront can be provisioned in this region.

Example of root module configuration:

```Terraform
# --- providers.tf ---

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}


# --- main.tf ---

module "website" {
  source  = "./terraform-aws-s3-website"
  version = "1.0.0"
  inputs...
  
  providers = {
    aws           = aws
    aws.us-east-1 = aws.us-east-1
  }
}
```
