resource "aws_cloudwatch_log_group" "ecs_task_web" {
  name              = "${var.env}_admin_ecs_task_web"
  retention_in_days = 7
}
resource "aws_security_group" "ecs" {
  name        = local.ecs_sg_name
  description = replace(local.ecs_sg_name, "-", "_")
  vpc_id      = var.vpc_id

  tags = {
    Name = local.ecs_sg_name
  }

  lifecycle {
    ignore_changes = [description, tags]
  }
}
resource "aws_security_group_rule" "ecs-egress" {
  security_group_id = aws_security_group.ecs.id

  type        = "egress"
  cidr_blocks = [local.internet_cidr]
  protocol    = "-1"
  from_port   = local.internet_port
  to_port     = local.internet_port
}
resource "aws_security_group_rule" "ecs-ingress-80" {
  security_group_id = aws_security_group.ecs.id

  type        = "ingress"
  cidr_blocks = [data.aws_vpc.default.cidr_block]
  protocol    = "tcp"
  from_port   = local.http_port
  to_port     = local.http_port
}
resource "aws_ecs_task_definition" "web" {
  family                   = local.name
  container_definitions    = data.template_file.ecs_task_web.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = data.aws_iam_role.ecs-task.arn
  cpu                      = 256
  memory                   = 512

  depends_on = [
    aws_cloudwatch_log_group.ecs_task_web
  ]

  lifecycle {
    ignore_changes = [container_definitions]
  }
}
resource "aws_ecs_service" "web" {
  name            = local.name
  cluster         = data.aws_ecs_cluster.web.id
  task_definition = aws_ecs_task_definition.web.arn
  launch_type     = "FARGATE"
  desired_count   = 0

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  scheduling_strategy                = "REPLICA"
  health_check_grace_period_seconds  = 300
  enable_ecs_managed_tags            = true
  propagate_tags                     = "SERVICE"

  network_configuration {
    security_groups  = [aws_security_group.ecs.id]
    subnets          = flatten(var.pri_ids)
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.lb_tg_blue.id
    container_name   = basename(var.ecr_app_url)
    container_port   = local.http_port
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  tags = {
    service = var.service_name
    env     = var.env
  }
  depends_on = [var.lb_listener_https]

  lifecycle {
    ignore_changes = [task_definition, load_balancer, desired_count, tags]
  }
}
resource "aws_appautoscaling_target" "web" {
  min_capacity       = 0
  max_capacity       = 0
  resource_id        = "service/${data.aws_ecs_cluster.web.cluster_name}/${aws_ecs_service.web.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  lifecycle {
    ignore_changes = [min_capacity, max_capacity]
  }
}
resource "aws_appautoscaling_policy" "web" {
  count = local.autoscaling_flg

  name               = "ECSServiceAverageCPUUtilization:${aws_appautoscaling_target.web.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.web.resource_id
  scalable_dimension = aws_appautoscaling_target.web.scalable_dimension
  service_namespace  = aws_appautoscaling_target.web.service_namespace

  # REF: https://tech.timee.co.jp/entry/2020/08/31/191612
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50
    scale_in_cooldown  = 300
    scale_out_cooldown = 100
  }

  depends_on = [aws_appautoscaling_target.web]
}