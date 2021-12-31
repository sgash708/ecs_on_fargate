variable "service_name" {}
locals {
  names = ["admin-${var.service_name}-image-base", "admin-${var.service_name}-image-app"]
}