resource "aws_security_group" "alb" {
  name        = "${local.name}-alb"
  description = "${var.env}:${var.service_name} LoadBalancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.name}-alb"
  }

  lifecycle {
    ignore_changes = [description]
  }
}
resource "aws_security_group_rule" "alb-egress" {
  security_group_id = aws_security_group.alb.id

  type        = "egress"
  cidr_blocks = [local.des_cidr]
  protocol    = "-1"
  from_port   = local.internet_port
  to_port     = local.internet_port
}
resource "aws_security_group_rule" "alb-ingress-443" {
  security_group_id = aws_security_group.alb.id

  type        = "ingress"
  from_port   = local.https_port
  to_port     = local.https_port
  protocol    = "tcp"
  cidr_blocks = [local.des_cidr]
}
resource "aws_security_group_rule" "alb-ingress-80" {
  security_group_id = aws_security_group.alb.id

  type        = "ingress"
  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = "tcp"
  cidr_blocks = [local.des_cidr]
}
resource "aws_lb" "web" {
  name               = "${local.name}-web"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = flatten(var.pub_ids)

  enable_deletion_protection = false

  access_logs {
    bucket  = "${var.service_name}-logs"
    enabled = true
    prefix  = "${var.env}/alb"
  }

  tags = {
    Name    = "${local.name}-web"
    service = var.service_name
    env     = var.env
  }
}
resource "aws_lb_target_group" "ecs-webs" {
  count = length(local.targets)

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
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web.arn
  port              = local.https_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs-webs[0].arn
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = local.http_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = local.https_port
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_route53_record" "lb-web" {
  zone_id = var.route53_zone.zone_id
  name    = "${var.env}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_lb.web.dns_name]
}