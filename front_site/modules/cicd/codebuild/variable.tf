variable "ecr_base_name" {}
variable "ecr_app_name" {}
variable "service_name" {}
variable "account_info" {}
locals {
  name = ["${var.service_name}-image-base", "${var.service_name}-image-app"]
}
