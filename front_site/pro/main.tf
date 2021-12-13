# Network
module "cloudfront" {
  source = "../modules/network/cloudfront"

  acm_arn_global = data.aws_acm_certificate.global.arn
  env            = var.env
  s3_info        = var.s3_info
}
module "vpc" {
  source = "../modules/network/vpc"

  env          = var.env
  service_name = var.service_name
  cidr         = var.vpc_cidr
}
module "alb" {
  source = "../modules/network/alb"

  vpc_id       = module.vpc.default.id
  pub_ids      = module.vpc.pub_ids
  acm_arn      = data.aws_acm_certificate.default.arn
  route53_zone = data.aws_route53_zone.default
  env          = var.env
  service_name = var.service_name
  domain_name  = var.domain_name
}
# DataBase
module "rds" {
  source = "../modules/db/rds"

  vpc          = module.vpc.default
  pri_ids      = module.vpc.pri_ids
  env          = var.env
  service_name = var.service_name
  db_info      = var.db_info
  snapshot_flg = true
}
# Container
module "ecs" {
  source = "../modules/container/ecs"

  vpc               = module.vpc.default
  lb_tg_blue        = module.alb.tg_blue
  lb_listener_https = module.alb.listener_https
  pri_ids           = module.vpc.pri_ids
  ecr_app_url       = data.aws_ecr_repository.app.repository_url
  env               = var.env
  service_name      = var.service_name
  account_info      = var.account_info
  ecs_info          = var.ecs_info
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
module "ssm" {
  source = "../modules/other/ssm"

  pri_ids      = module.vpc.pri_ids
  rds_sg_id    = module.rds.sg_id
  env          = var.env
  service_name = var.service_name
}
module "waf" {
  source = "../modules/other/waf"

  alb_arn      = module.alb.lb.arn
  env          = var.env
  account_info = var.account_info
  s3_info      = var.s3_info
}
