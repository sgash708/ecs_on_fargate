variable "vpc" {}
variable "env" {}
variable "service_name" {}
variable "pri_ids" {}
variable "db_info" {}
variable "snapshot_flg" {}
locals {
  name                      = "${var.env}-${var.service_name}"
  internet_port             = 0
  internet_cidr             = "0.0.0.0/0"
  replica_flg               = var.env != "ww9" ? 1 : 0
  backtrack_window_minutes  = var.env != "ww9" ? 86400 : 43200
  backup_retention_days     = var.env != "ww9" ? 7 : 1
  is_lambda_function_enable = var.env != "ww9" ? false : true
}
