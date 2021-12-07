data "aws_route53_zone" "default" {
  name         = var.domain_name
  private_zone = false
}
data "aws_acm_certificate" "default" {
  domain = "*.${var.domain_name}"
}
data "aws_acm_certificate" "global" {
  domain   = "*.${var.domain_name}"
  provider = aws.global
}
data "aws_ecr_repository" "app" {
  name = "${var.service_name}-app"
}
