resource "aws_s3_bucket_policy" "cloudfront" {
  bucket = data.aws_s3_bucket.image.id
  policy = data.aws_iam_policy_document.cloudfront.json
}
resource "aws_cloudfront_origin_access_identity" "cloudfront" {
  comment = "origin access identity for ${var.env}-s3"
}
resource "aws_cloudfront_distribution" "cloudfront" {
  # ルートアクセス防止
  default_root_object = "index.html"
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_200"
  aliases             = [lookup(var.s3_info, "image_bucket_domain_name")]

  origin {
    domain_name = data.aws_s3_bucket.image.bucket_regional_domain_name
    origin_id   = data.aws_s3_bucket.image.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront.cloudfront_access_identity_path
    }
  }

  logging_config {
    include_cookies = false
    bucket          = lookup(var.s3_info, "log_bucket_url")
    prefix          = "${var.env}/cloudfront/"
  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "POST",
      "PUT",
      "PATCH",
      "DELETE",
    ]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = data.aws_s3_bucket.image.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    env = var.env
  }

  # 全てのブラウザに対応させない
  viewer_certificate {
    acm_certificate_arn      = var.acm_arn_global
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2019"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

# TODO: [手作業]Route53はAレコードでCloudFront連携