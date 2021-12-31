data "aws_iam_role" "ecs-task" {
  name = "ecsTaskExecutionRole"
}
data "aws_ecs_cluster" "web" {
  cluster_name = local.ecs_cluster_name
}
data "template_file" "ecs_task_web" {
  template = file("./ecs_task.json")

  vars = {
    env       = lookup(var.ecs_info, "env")
    region    = lookup(var.account_info, "region")
    command   = lookup(var.ecs_info, "command")
    image     = var.ecr_app_url
    log_group = aws_cloudwatch_log_group.ecs_task_web.name
  }
}
data "aws_vpc" "default" {
  id = var.vpc_id
}