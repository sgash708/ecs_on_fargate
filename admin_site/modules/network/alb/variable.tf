variable "route53_zone" {}
variable "env" {}
variable "service_name" {}
variable "domain_name" {}
variable "subdomain_name" {}
variable "vpc_id" {}
variable "alb_arn" {}
locals {
  name                = "${var.env}-admin-${var.service_name}"
  perfect_domain_name = "${var.subdomain_name}.${var.domain_name}"
  targets             = ["${local.name}-web-ecs-blue", "${local.name}-web-ecs-green"]
  des_cidr            = "0.0.0.0/0"
  https_port          = 443
  http_port           = 80
  time_out_seconds    = 3
  allow_status_codes  = ["200", "302", "401"]
}