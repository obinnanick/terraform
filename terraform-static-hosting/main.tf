terraform {
  required_providers{
    aws = {
        source="hashicorp/aws"
        version="~>4.0"
    }
  }
}
provider "aws" {
    region = var.aws_region
}
module "template_files" {
  source = "hashicorp/dir/template"
  
  base_dir ="${path.module}/web"
}
resource "aws_s3_bucket" "my-bucket" {
    bucket = var.bucket_name
}
resource "aws_s3_bucket_acl" "my-bucket_acl" {
  bucket = aws_s3_bucket.my-bucket.id
  acl = "public-read"
}
resource "aws_s3_bucket_policy" "my-bucket_policy" {
  bucket = aws_s3_bucket.my-bucket.id
  policy = jsondecode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3::: ${var.bucket_name}/*"
        }
    ]
})
}
resource "aws_s3_bucket_website_configuration" "hosting_aws_website_configuration" {
  bucket = aws_s3_bucket.my-bucket.id
  index_document {
    suffix ="index.html"
  }
}
resource "aws_s3_object" "hosting_bucket_files" {
  bucket = aws_s3_bucket.my-bucket.id

  for_each = module-template_files.files
  key = each.key
  content_type = each.value.content_type

  source = each.value.source.path
  content = each.value.content

  etag = each.value.digests.md5
}