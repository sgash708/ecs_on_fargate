variable "lb_tg_blue" {}
variable "lb_listener_https" {}
variable "ecr_app_url" {}
variable "env" {}
variable "service_name" {}
variable "account_info" {}
variable "ecs_info" {}
variable "pri_ids" {}
variable "vpc_id" {}
locals {
  name             = format("%s-%s-%s-%s", var.env, "admin", var.service_name, "web")
  ecs_cluster_name = format("%s-%s-%s", var.env, var.service_name, "web")
  ecs_sg_name      = format("%s-%s-%s-%s", var.env, "admin", var.service_name, "ecs")
  autoscaling_flg  = var.env != "ww9" ? 1 : 0
  http_port        = 80
  internet_port    = 0
  internet_cidr    = "0.0.0.0/0"
}