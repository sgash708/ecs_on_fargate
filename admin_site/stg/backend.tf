terraform {
  backend "s3" {
    bucket = "SugarSatoIsASampleCode"
    key    = "niceservicename/tfstate/admin_site/ww9"
    region = "ap-northeast-1"
  }
  required_version = ">= 0.12"
}