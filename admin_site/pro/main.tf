# Network
module "alb" {
  source = "../modules/network/alb"

  route53_zone   = data.aws_route53_zone.default
  env            = var.env
  service_name   = var.service_name
  domain_name    = var.domain_name
  subdomain_name = var.subdomain_name
  vpc_id         = lookup(var.network_info, "vpc_id")
  alb_arn        = lookup(var.network_info, "alb_arn")
}
# Container
module "ecs" {
  source = "../modules/container/ecs"

  lb_tg_blue        = module.alb.tg_blue
  lb_listener_https = module.alb.listener_https
  ecr_app_url       = data.aws_ecr_repository.app.repository_url
  env               = var.env
  service_name      = var.service_name
  account_info      = var.account_info
  ecs_info          = var.ecs_info
  vpc_id            = lookup(var.network_info, "vpc_id")
  pri_ids           = lookup(var.network_info, "pri_ids")
}
# CI/CD
module "codedeploy" {
  source = "../modules/cicd/codedeploy"

  lb_listener_https            = module.alb.listener_https
  lb_tg_blue_name              = module.alb.tg_blue.name
  lb_tg_green_name             = module.alb.tg_green.name
  ecs_cluster_name             = module.ecs.web_cluster_name
  ecs_service_name             = module.ecs.web_service_name
  env                          = var.env
  service_name                 = var.service_name
  waiting_minutes_after_deploy = 5
}
# Other
module "cognito" {
  source = "../modules/other/cognito"

  env            = var.env
  service_name   = var.service_name
  domain_name    = var.domain_name
  subdomain_name = var.subdomain_name
}