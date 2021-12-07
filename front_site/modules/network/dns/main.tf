resource "aws_acm_certificate" "default" {
  domain_name       = local.all_sub_domain
  validation_method = local.validation_method

  tags = {
    Name    = local.tag_name
    service = var.service_name
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}
resource "aws_acm_certificate" "global" {
  provider          = aws.global
  domain_name       = local.all_sub_domain
  validation_method = local.validation_method

  tags = {
    Name    = "use1-${local.tag_name}"
    service = var.service_name
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }
}