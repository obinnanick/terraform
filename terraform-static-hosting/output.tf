output "website_url" {
  description = "url of the website"
  value = aws_s3_bucket_website_configuration.hosting_aws_website_configuration.website_endpoint
}