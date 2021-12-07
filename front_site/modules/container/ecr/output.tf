output "base" {
  value = aws_ecr_repository.repos[0]
}
output "app" {
  value = aws_ecr_repository.repos[1]
}