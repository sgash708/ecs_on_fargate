variable "env" {}
variable "service_name" {}
variable "domain_name" {}
variable "subdomain_name" {}
locals {
  cognito_name = "${var.env}-${var.service_name}"
  admin_domain = "${var.subdomain_name}.${var.domain_name}"
  front_domain = "${var.env}.${var.domain_name}"
}