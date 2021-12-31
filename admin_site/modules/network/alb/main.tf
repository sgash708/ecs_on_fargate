resource "aws_lb_target_group" "ecs-webs" {
  count = length(local.targets)

  # WARN: Error: "name" cannot be longer than 32 characters
  name                 = local.targets[count.index]
  vpc_id               = var.vpc_id
  port                 = local.http_port
  protocol             = "HTTP"
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = local.http_port
    interval            = 10
    timeout             = local.time_out_seconds
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = join(",", local.allow_status_codes)
  }
}
resource "aws_lb_listener_rule" "web" {
  listener_arn = data.aws_lb_listener.https.arn
  priority     = 150

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-webs[0].arn
  }

  condition {
    host_header {
      values = [local.perfect_domain_name]
    }
  }

  lifecycle {
    ignore_changes = [action]
  }
}
resource "aws_route53_record" "lb-web" {
  zone_id = var.route53_zone.zone_id
  name    = local.perfect_domain_name
  type    = "CNAME"
  ttl     = 60
  records = [data.aws_lb.web.dns_name]
}