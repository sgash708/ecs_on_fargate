variable "cidr" {}
variable "env" {}
variable "service_name" {}
locals {
  availablity_zones   = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
  internet_cidr       = "0.0.0.0/0"
  service_name        = "${var.env}-${var.service_name}"
  security_group_name = "vpc_endpoint_sg"
  https_port          = 443
  internet_port       = 0
}