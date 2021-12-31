variable "lb_listener_https" {}
variable "lb_tg_blue_name" {}
variable "lb_tg_green_name" {}
variable "ecs_cluster_name" {}
variable "ecs_service_name" {}
variable "env" {}
variable "service_name" {}
variable "waiting_minutes_after_deploy" {}
locals {
  name = format("%s-%s-%s", var.env, var.service_name, "web")
}