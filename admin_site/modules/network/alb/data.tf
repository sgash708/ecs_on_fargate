data "aws_lb" "web" {
  arn  = var.alb_arn
  name = "${local.name}-web"
}
data "aws_lb_listener" "https" {
  load_balancer_arn = data.aws_lb.web.arn
  port              = local.https_port
}