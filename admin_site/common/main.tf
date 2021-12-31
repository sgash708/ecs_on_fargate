module "ecr" {
  source = "../modules/container/ecr"

  service_name = var.service_name
}
module "codebuild" {
  source = "../modules/cicd/codebuild"

  ecr_base_name = module.ecr.base.name
  ecr_app_name  = module.ecr.app.name
  service_name  = var.service_name
  account_info  = var.account_info
}
