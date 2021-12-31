output "web_cluster_name" {
  value = aws_ecs_cluster.web.name
}
output "web_service_name" {
  value = aws_ecs_service.web.name
}