variable "vpc" {}
variable "lb_tg_blue" {}
variable "lb_listener_https" {}
variable "pri_ids" {}
variable "ecr_app_url" {}
variable "env" {}
variable "service_name" {}
variable "account_info" {}
variable "ecs_info" {}
locals {
  name            = format("%s-%s-%s", var.env, var.service_name, "web")
  region          = lookup(var.account_info, "region")
  id              = lookup(var.account_info, "id")
  ecs_env         = lookup(var.ecs_info, "env")
  ecs_command     = lookup(var.ecs_info, "command")
  autoscaling_flg = var.env != "ww9" ? 1 : 0
  http_port       = 80
  internet_port   = 0
  internet_cidr   = "0.0.0.0/0"
}