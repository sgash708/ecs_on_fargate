resource "aws_ecr_repository" "repos" {
  count = length(local.names)

  name = local.names[count.index]
}
resource "aws_ecr_lifecycle_policy" "policies" {
  count = length(local.names)

  repository = aws_ecr_repository.repos[count.index].name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire images older than 1 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 1
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}