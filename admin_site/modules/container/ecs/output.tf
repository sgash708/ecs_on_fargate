output "web_cluster_name" {
  value = data.aws_ecs_cluster.web.cluster_name
}
output "web_service_name" {
  value = aws_ecs_service.web.name
}