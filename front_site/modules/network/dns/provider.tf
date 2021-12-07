# REF: https://dev.classmethod.jp/articles/terraform-015/#toc-6
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.global]
    }
  }
}
