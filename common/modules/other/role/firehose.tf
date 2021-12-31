resource "aws_iam_role" "firehose" {
  name               = "KinesisFirehoseServiceRole-aws-waf--${local.region}-111111111"
  path               = "/service-role/"
  assume_role_policy = <<eof
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
eof
}
# TODO: attachはstg/pro環境で行う
# resource "aws_iam_role_policy_attachment" "firehose" {}