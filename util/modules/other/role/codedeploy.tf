resource "aws_iam_role" "ecs-codedeploy" {
  name               = "ecsCodeDeployRole"
  assume_role_policy = <<eof
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
eof
}
resource "aws_iam_role_policy_attachment" "ecs-codedeploy" {
  role       = aws_iam_role.ecs-codedeploy.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}