variable "cloudfront_default_ttl" {
  type        = number
  description = "Default TTL for pages in CloudFront cache"
  default     = 86400
}

variable "cloudfront_error_page" {
  type        = string
  description = "The object that CloudFront serves when a 404 error is returned"
  default     = "404.html"
}

variable "cloudfront_price_class" {
  type        = string
  description = "Price class for the distribution serving the website (PriceClass_All, PriceClass_200, PriceClass_100)"
  default     = "PriceClass_100"
}

variable "cloudfront_root_object" {
  type        = string
  description = "The object that CloudFront serves when the root URL is requested"
  default     = "index.html"
}

variable "website_domain" {
  type        = string
  description = "Website domain name including TLD e.g. mywebsite.com"
}

variable "website_tags" {
  type        = map(string)
  description = "Tags for the production website resources"
}

variable "website_test_ip_whitelist" {
  type        = list(string)
  description = "IPs allowed to access the test website"
}

variable "website_test_tags" {
  type        = map(string)
  description = "Tags for the test website resources"
}
