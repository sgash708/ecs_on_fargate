data "aws_s3_bucket" "firehose" {
  bucket = lookup(var.s3_info, "log_bucket_name")
}
data "aws_iam_role" "firehose" {
  name = "KinesisFirehoseServiceRole-aws-waf--${local.region}-111111111"
}