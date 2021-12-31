resource "aws_iam_role" "ecs-task" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = <<eof
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
eof
}
resource "aws_iam_role_policy" "ecs-task" {
  name   = "ecsTaskExecutionRolePolicy"
  role   = aws_iam_role.ecs-task.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ssm:GetParameters",
        "ssm:DescribeParameters",
        "ssm:GetParameter",
        "ssm:GetParameterHistory",
        "secretsmanager:GetSecretValue",
        "kms:Decrypt"
      ],
      "Resource": [
        "arn:aws:ssm:${local.region}:${local.id}:parameter/*",
        "arn:aws:kms:${local.region}:${local.id}:alias/aws/ssm"
      ]
    }
  ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "ecs-task" {
  role       = aws_iam_role.ecs-task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}