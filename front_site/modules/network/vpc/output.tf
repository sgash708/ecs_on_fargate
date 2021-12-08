output "default" {
  value = aws_vpc.default
}
output "pub_ids" {
  value = [aws_subnet.publics.*.id]
}
output "pri_ids" {
  value = [aws_subnet.privates.*.id]
}
