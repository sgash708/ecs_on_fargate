output "tg_blue" {
  value = aws_lb_target_group.ecs-webs[0]
}
output "tg_green" {
  value = aws_lb_target_group.ecs-webs[1]
}
output "listener_https" {
  value = data.aws_lb_listener.https
}