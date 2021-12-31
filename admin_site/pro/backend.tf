terraform {
  backend "s3" {
    bucket = "SugarSatoIsASampleCode"
    key    = "niceservicename/tfstate/admin_site/www"
    region = "ap-northeast-1"
  }
  required_version = ">= 0.12"
}