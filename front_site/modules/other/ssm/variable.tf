variable "pri_ids" {}
variable "rds_sg_id" {}
variable "env" {}
variable "service_name" {}
locals {
  name = "${var.env}-${var.service_name}-private-db-maintainance"
}