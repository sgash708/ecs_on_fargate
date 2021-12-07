resource "aws_cloudwatch_log_group" "codebuilds" {
  count = length(local.name)

  name              = "/aws/codebuild/${local.name[count.index]}"
  retention_in_days = 7
}
resource "aws_iam_role" "codebuild" {
  name               = "CodeBuildServiceRole"
  assume_role_policy = <<eof
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
eof
}
resource "aws_iam_role_policy" "codebuild" {
  name   = "CodeBuildServiceRolePolicy"
  role   = aws_iam_role.codebuild.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codecommit:Gitpull",
        "ec2:Describe*",
        "ec2:CreateNetworkInterface",
        "ec2:CreateNetworkInterfacePermission",
        "ec2:DeleteNetworkInterface",
        "logs:CreategLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}
resource "aws_codebuild_project" "applications" {
  count = length(local.name)

  name          = local.name[count.index]
  description   = "Building image for ${local.name[count.index]}"
  service_role  = aws_iam_role.codebuild.arn
  build_timeout = 10

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0-21.04.23"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = lookup(var.account_info, "region")
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = lookup(var.account_info, "id")
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = count.index == 0 ? var.ecr_base_name : var.ecr_app_name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }
  }

  source {
    git_clone_depth = 1
    type            = "GITHUB"
    location        = "${lookup(var.account_info, "gh_org_url")}/${local.name[count.index]}.git"

    git_submodules_config {
      fetch_submodules = false
    }
  }

  tags = {
    service = var.service_name
  }

  lifecycle {
    ignore_changes = [description, tags]
  }
}
resource "aws_codebuild_webhook" "image-base" {
  project_name = aws_codebuild_project.applications[0].name
  build_type   = "BUILD"

  filter_group {
    filter {
      exclude_matched_pattern = false
      pattern                 = "PUSH"
      type                    = "EVENT"
    }
    filter {
      exclude_matched_pattern = false
      pattern                 = "^refs/heads/master$"
      type                    = "HEAD_REF"
    }
  }
}