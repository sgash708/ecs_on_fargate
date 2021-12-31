provider "aws" {
  region = lookup(var.account_info, "region")
}