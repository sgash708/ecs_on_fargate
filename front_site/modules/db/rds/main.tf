resource "aws_security_group" "mysql" {
  name        = "${local.name}-mysql"
  description = "${local.name}s Security Group"
  vpc_id      = var.vpc.id

  tags = {
    Name = "${local.name}-mysql"
  }

  lifecycle {
    ignore_changes = [description, tags]
  }
}
resource "aws_security_group_rule" "mysql-egress" {
  security_group_id = aws_security_group.mysql.id

  type        = "egress"
  cidr_blocks = [local.internet_cidr]
  protocol    = "-1"
  from_port   = local.internet_port
  to_port     = local.internet_port
}
resource "aws_security_group_rule" "mysql-ingress-3306" {
  security_group_id = aws_security_group.mysql.id

  type        = "ingress"
  from_port   = lookup(var.db_info, "DB_PORT")
  to_port     = lookup(var.db_info, "DB_PORT")
  protocol    = "tcp"
  cidr_blocks = [var.vpc.cidr_block]
}
resource "aws_db_subnet_group" "mysql" {
  name        = local.name
  description = "${local.name} DB Subnet Group"
  subnet_ids  = flatten(var.pri_ids)

  lifecycle {
    ignore_changes = [description]
  }
}
resource "aws_db_parameter_group" "mysql" {
  name   = local.name
  family = "aurora-mysql5.7"

  parameter {
    apply_method = "immediate"
    name         = "log_queries_not_using_indexes"
    value        = 1
  }
  parameter {
    apply_method = "immediate"
    name         = "long_query_time"
    value        = 5
  }
  parameter {
    apply_method = "immediate"
    name         = "slow_query_log"
    value        = 1
  }
}
resource "aws_rds_cluster_parameter_group" "mysql" {
  name        = local.name
  family      = "aurora-mysql5.7"
  description = "Cluster parameter for ${local.name}"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
  parameter {
    name  = "server_audit_logging"
    value = 1
  }
  parameter {
    name  = "general_log"
    value = 1
  }
  parameter {
    name  = "server_audit_logging"
    value = 1
  }
  parameter {
    name  = "server_audit_logs_upload"
    value = 1
  }
  parameter {
    name  = "server_audit_events"
    value = "CONNECT,QUERY,QUERY_DCL,QUERY_DDL,QUERY_DML,TABLE"
  }
  parameter {
    apply_method = "immediate"
    name         = "log_queries_not_using_indexes"
    value        = 1
  }
  parameter {
    apply_method = "immediate"
    name         = "log_slow_admin_statements"
    value        = 1
  }
  parameter {
    apply_method = "immediate"
    name         = "log_slow_slave_statements"
    value        = 1
  }
  parameter {
    apply_method = "immediate"
    name         = "slow_query_log"
    value        = 1
  }

  lifecycle {
    ignore_changes = [description]
  }
}
resource "aws_rds_cluster" "rds" {
  cluster_identifier     = local.name
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.mysql.id]

  engine         = "aurora-mysql"
  engine_version = "5.7.mysql_aurora.2.07.5"
  enabled_cloudwatch_logs_exports = [
    "audit",
    "error",
    "general",
    "slowquery",
  ]

  database_name                   = lookup(var.db_info, "DB_NAME")
  master_username                 = lookup(var.db_info, "DB_ROOT")
  master_password                 = lookup(var.db_info, "DB_PASSWORD")
  port                            = lookup(var.db_info, "DB_PORT")
  backtrack_window                = local.backtrack_window_minutes
  backup_retention_period         = local.backup_retention_days
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.mysql.name

  deletion_protection            = true
  enable_global_write_forwarding = false
  skip_final_snapshot            = var.snapshot_flg

  tags = {
    AUTO_STARTSTOP = local.is_lambda_function_enable
  }

  lifecycle {
    ignore_changes = [master_password, tags]
  }
}
resource "aws_rds_cluster_instance" "rds" {
  identifier              = local.name
  cluster_identifier      = aws_rds_cluster.rds.id
  promotion_tier          = 1
  engine                  = aws_rds_cluster.rds.engine
  instance_class          = lookup(var.db_info, "INSTANCE_SIZE")
  db_parameter_group_name = aws_db_parameter_group.mysql.name
}
resource "aws_rds_cluster_instance" "replica-rds" {
  count = local.replica_flg

  identifier              = "rep-${local.name}"
  cluster_identifier      = aws_rds_cluster.rds.id
  promotion_tier          = 1
  engine                  = aws_rds_cluster.rds.engine
  engine_version          = aws_rds_cluster.rds.engine_version
  instance_class          = lookup(var.db_info, "INSTANCE_SIZE")
  db_parameter_group_name = aws_db_parameter_group.mysql.name
}
