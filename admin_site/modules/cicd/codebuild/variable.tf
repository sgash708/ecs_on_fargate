variable "ecr_base_name" {}
variable "ecr_app_name" {}
variable "service_name" {}
variable "account_info" {}
locals {
  name = ["admin-${var.service_name}-image-base", "admin-${var.service_name}-image-app"]
}
