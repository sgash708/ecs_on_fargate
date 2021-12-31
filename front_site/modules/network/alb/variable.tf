variable "vpc_id" {}
variable "pub_ids" {}
variable "route53_zone" {}
variable "acm_arn" {}
variable "env" {}
variable "service_name" {}
variable "domain_name" {}
locals {
  name               = "${var.env}-${var.service_name}"
  targets            = ["${local.name}-web-ecs-blue", "${local.name}-web-ecs-green"]
  des_cidr           = "0.0.0.0/0"
  https_port         = 443
  http_port          = 80
  internet_port      = 0
  time_out_seconds   = var.env != "ww9" ? 5 : 3
  allow_status_codes = ["200", "401"]
}