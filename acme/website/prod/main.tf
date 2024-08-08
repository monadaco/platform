provider "aws" {
  region = "us-west-2"  # Change this to your preferred AWS region
}

resource "aws_s3_bucket" "static_website" {
  bucket = "your-static-website-bucket"  # Change this to your bucket name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_object" "index" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "index.html"
  source = "path/to/your/index.html"  # Change this to the path of your index.html
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "error" {
  bucket = aws_s3_bucket.static_website.bucket
  key    = "error.html"
  source = "path/to/your/error.html"  # Change this to the path of your error.html
  acl    = "public-read"
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for static website"
}

resource "aws_s3_bucket_policy" "s3_policy" {
  bucket = aws_s3_bucket.static_website.bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${aws_cloudfront_origin_access_identity.oai.id}"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_website.arn}/*"
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket.static_website.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.static_website.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Static website distribution"
  default_root_object = "index.html"

  aliases = ["www.yourwebsite.com"]  # Change this to your domain name

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.static_website.bucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}
