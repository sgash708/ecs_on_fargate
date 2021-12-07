provider "aws" {
  region = lookup(var.account_info, "region")
}
provider "aws" {
  region = lookup(var.account_info, "global_region")
  alias  = "global"
}