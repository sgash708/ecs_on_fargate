resource "aws_cognito_user_pool" "user_pool" {
  alias_attributes           = ["preferred_username"]
  auto_verified_attributes   = ["email"]
  mfa_configuration          = "OFF"
  name                       = local.cognito_name
  sms_authentication_message = " 認証コードは {####} です。"

  account_recovery_setting {
    recovery_mechanism {
      name     = "admin_only"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_message = " ユーザー名は {username}、仮パスワードは {####} です。"
      email_subject = " 仮パスワード"
      sms_message   = " ユーザー名は {username}、仮パスワードは {####} です。"
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = 2048
      min_length = 0
    }
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = " 検証コードは {####} です。"
    email_subject        = " 検証コード"
    sms_message          = " 検証コードは {####} です。"
  }

  tags = {
    ENV = local.cognito_name
  }
}
resource "aws_cognito_user_pool_client" "user_pool_client" {
  access_token_validity                = 60
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                 = ["openid"]

  callback_urls = [
    "https://${local.front_domain}/oauth2/idpresponse",
    "https://${local.admin_domain}/oauth2/idpresponse",
  ]
  explicit_auth_flows           = ["ALLOW_REFRESH_TOKEN_AUTH"]
  id_token_validity             = 60
  logout_urls                   = []
  name                          = local.cognito_name
  prevent_user_existence_errors = "ENABLED"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  refresh_token_validity       = 7
  supported_identity_providers = ["COGNITO"]
  user_pool_id                 = aws_cognito_user_pool.user_pool.id
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}
resource "aws_cognito_user_pool_domain" "domain" {
  domain       = local.cognito_name
  user_pool_id = aws_cognito_user_pool.user_pool.id
}