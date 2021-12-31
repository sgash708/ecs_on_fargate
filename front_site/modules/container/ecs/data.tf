data "template_file" "ecs_task_web" {
  template = file("./ecs_task.json")

  vars = {
    env       = local.ecs_env
    region    = local.region
    command   = local.ecs_command
    image     = var.ecr_app_url
    log_group = aws_cloudwatch_log_group.ecs_task_web.name
  }
}
data "aws_iam_role" "ecs-task" {
  name = "ecsTaskExecutionRole"
}