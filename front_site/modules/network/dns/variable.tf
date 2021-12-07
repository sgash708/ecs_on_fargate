variable "account_info" {}
variable "domain_name" {}
variable "service_name" {}
locals {
  tag_name          = lookup(var.account_info, "acm_name")
  all_sub_domain    = "*.${var.domain_name}"
  validation_method = "DNS"
}