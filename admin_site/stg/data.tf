data "aws_route53_zone" "default" {
  name         = var.domain_name
  private_zone = false
}
data "aws_ecr_repository" "app" {
  name = "admin-${var.service_name}-image-app"
}
