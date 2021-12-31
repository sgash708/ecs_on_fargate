resource "aws_iam_instance_profile" "ssm" {
  name = "MyInstanceSSMProfile"
  role = data.aws_iam_role.ssm.name
}
resource "aws_instance" "private" {
  ami                    = "ami-0f310fced6141e627"
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ssm.name
  subnet_id              = flatten(var.pri_ids)[0]
  vpc_security_group_ids = [var.rds_sg_id]
  user_data              = file("../modules/other/ssm/install.sh")
  key_name               = aws_key_pair.secret.id

  credit_specification {
    cpu_credits = "standard"
  }

  tags = {
    Name = local.name
  }

  lifecycle {
    ignore_changes = [tags]
  }
}
resource "aws_key_pair" "secret" {
  key_name   = local.name
  public_key = file("./${var.env}.pub")

  lifecycle {
    ignore_changes = [public_key]
  }
}