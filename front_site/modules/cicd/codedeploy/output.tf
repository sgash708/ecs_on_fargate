output "deploy_group_name" {
  value = aws_codedeploy_deployment_group.web.deployment_group_name
}
output "deploy_application_name" {
  value = aws_codedeploy_app.web.name
}