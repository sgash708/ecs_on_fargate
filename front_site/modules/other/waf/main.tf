resource "aws_cloudwatch_log_group" "firehose" {
  name              = "/aws/kinesisfirehose/aws-waf-logs-${var.env}"
  retention_in_days = 0
}
resource "aws_iam_role_policy_attachment" "firehose" {
  role       = data.aws_iam_role.firehose.name
  policy_arn = "arn:aws:iam::${local.id}:policy/service-role/KinesisFirehoseServicePolicy-aws-waf-logs-${var.env}-${local.region}"
}
resource "aws_kinesis_firehose_delivery_stream" "s3" {
  name        = "aws-waf-logs-${var.env}"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn            = data.aws_iam_role.firehose.arn
    bucket_arn          = data.aws_s3_bucket.firehose.arn
    s3_backup_mode      = "Disabled"
    error_output_prefix = "${var.env}/waf/!{firehose:error-output-type}/!{timestamp:yyyy}-!{timestamp:MM}-!{timestamp:dd}/"
    prefix              = "${var.env}/waf/!{timestamp:yyyy}-!{timestamp:MM}-!{timestamp:dd}/"
    compression_format  = "GZIP"

    buffer_interval = 900
    buffer_size     = local.firehose_buffer_size

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose.name
      log_stream_name = "S3Delivery"
    }

    processing_configuration {
      enabled = false
    }
  }
}
resource "aws_wafv2_regex_pattern_set" "wl_upload_extension" {
  name  = "${local.regex_prefix_name}ImageUploadExtension"
  scope = "REGIONAL"

  regular_expression {
    regex_string = ".*\\.jpeg"
  }
  regular_expression {
    regex_string = ".*\\.png"
  }
  regular_expression {
    regex_string = ".*\\.jpg"
  }

  lifecycle {
    ignore_changes = [description, tags]
  }
}
resource "aws_wafv2_regex_pattern_set" "wl_upload_path" {
  name  = "${local.regex_prefix_name}ImageUploadPath"
  scope = "REGIONAL"

  # NOTICE: Terraformは、Golangでの開発のためシングルクォート使用不可
  regular_expression {
    regex_string = "^.*\\/.*_image\\/(confirm|save)$"
  }

  lifecycle {
    ignore_changes = [description, tags]
  }
}
resource "aws_wafv2_regex_pattern_set" "wl_path" {
  name  = "${local.regex_prefix_name}Path"
  scope = "REGIONAL"

  regular_expression {
    regex_string = "^\\/column\\/[0-9]+\\/(confirm|)(\\/|)$"
  }

  lifecycle {
    ignore_changes = [description, tags]
  }
}
resource "aws_wafv2_web_acl" "waf" {
  name        = "${var.env}_WAF"
  description = "for ${var.env}"
  scope       = "REGIONAL"

  default_action {
    allow {
    }
  }

  rule {
    name     = "IgnoreList"
    priority = 1
    action {
      allow {
      }
    }

    statement {
      regex_pattern_set_reference_statement {
        arn = aws_wafv2_regex_pattern_set.wl_path.arn
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }

    visibility_config {
      metric_name                = "IgnoreList"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "WhiteListImageUpload"
    priority = 0
    action {
      allow {
      }
    }

    statement {
      and_statement {
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.wl_upload_path.arn
            field_to_match {
              uri_path {}
            }
            text_transformation {
              priority = 0
              type     = "URL_DECODE"
            }
          }
        }
        statement {
          regex_pattern_set_reference_statement {
            arn = aws_wafv2_regex_pattern_set.wl_upload_extension.arn
            field_to_match {
              body {}
            }
            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      metric_name                = "WhiteListImageUpload"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
        excluded_rule {
          name = "SizeRestrictions_BODY"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = "AWS-AWSManagedRulesKnownBadInputsRuleSet"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    metric_name                = "${var.env}_WAF"
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }

  lifecycle {
    ignore_changes = [description, tags]
  }
}
resource "aws_wafv2_web_acl_association" "waf" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.waf.arn
}
resource "aws_wafv2_web_acl_logging_configuration" "waf" {
  log_destination_configs = [aws_kinesis_firehose_delivery_stream.s3.arn]
  resource_arn            = aws_wafv2_web_acl.waf.arn

  logging_filter {
    default_behavior = "DROP"

    filter {
      behavior    = "KEEP"
      requirement = "MEETS_ANY"

      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      condition {
        action_condition {
          action = "COUNT"
        }
      }
    }
  }
}