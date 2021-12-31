module "role" {
  source = "../modules/other/iam"

  account_info = var.account_info
}