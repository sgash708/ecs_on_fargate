variable "service_name" {}
locals {
  names = ["${var.service_name}-base", "${var.service_name}-app"]
}