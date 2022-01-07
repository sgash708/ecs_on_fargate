variable "account_info" {}
locals {
  id     = lookup(var.account_info, "id")
  region = lookup(var.account_info, "region")
}