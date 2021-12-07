data "aws_s3_bucket" "image" {
  bucket = lookup(var.s3_info, "image_bucket_name")
}
data "aws_iam_policy_document" "cloudfront" {
  statement {
    actions = ["s3:GetObject", "s3:ListBucket"]

    resources = [
      data.aws_s3_bucket.image.arn,
      "${data.aws_s3_bucket.image.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.cloudfront.iam_arn]
    }
  }
}
