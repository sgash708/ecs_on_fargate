# ネットワーク
module "dns" {
  source = "../modules/network/dns"

  providers = {
    aws.global = aws.global
  }

  account_info = var.account_info
  domain_name  = var.domain_name
  service_name = var.service_name
}
# コンテナ
module "ecr" {
  source = "../modules/container/ecr"

  service_name = var.service_name
}
# CI/CD
module "codebuild" {
  source = "../modules/cicd/codebuild"

  ecr_base_name = module.ecr.base.name
  ecr_app_name  = module.ecr.app.name
  service_name  = var.service_name
  account_info  = var.account_info
}

#####################
# 削除予定
#####################
# CI/CD
module "codecommit" {
  source = "../modules/cicd/codecommit"

  service_name = var.service_name
}
module "codepipeline" {
  source = "../modules/cicd/codepipeline"

  cc_base_repo_name    = module.codecommit.base_repo_name
  cc_app_repo_name     = module.codecommit.app_repo_name
  cb_base_project_name = module.codebuild.base_project_name
  cb_app_project_name  = module.codebuild.app_project_name
  account_info         = var.account_info
  s3_info              = var.s3_info
  cd_info              = var.cd_info
}
