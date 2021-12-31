variable "alb_arn" {}
variable "env" {}
variable "account_info" {}
variable "s3_info" {}
locals {
  id                   = lookup(var.account_info, "id")
  region               = lookup(var.account_info, "region")
  regex_prefix_name    = "WhiteList"
  firehose_buffer_size = var.env != "ww9" ? 100 : 10
}