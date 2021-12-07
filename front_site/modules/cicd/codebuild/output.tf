output "base_project_name" {
  value = aws_codebuild_project.applications[0].name
}
output "app_project_name" {
  value = aws_codebuild_project.applications[1].name
}
