#####################
# Common Settings
#####################
resource "aws_vpc" "default" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true

  tags = {
    "Name" = local.service_name
  }
}
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = {
    "Name" = local.service_name
  }
}

#####################
# Public Settings
#####################
resource "aws_subnet" "publics" {
  count = length(local.availablity_zones)

  vpc_id            = aws_vpc.default.id
  availability_zone = local.availablity_zones[count.index]
  cidr_block        = cidrsubnet(var.cidr, 8, count.index + 1)

  tags = {
    "Name" = "${local.service_name}-public-${count.index + 1}"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id

  tags = {
    "Name" = "${local.service_name}-public"
  }
}
resource "aws_route" "public" {
  destination_cidr_block = local.internet_cidr
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.default.id
}
resource "aws_route_table_association" "publics" {
  count = length(local.availablity_zones)

  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.publics.*.id, count.index)
}
resource "aws_eip" "nats" {
  count = length(local.availablity_zones)

  vpc = true

  tags = {
    Name = "${local.service_name}-natgw-${count.index + 1}"
  }
}
resource "aws_nat_gateway" "nats" {
  count = length(local.availablity_zones)

  subnet_id     = element(aws_subnet.publics.*.id, count.index)
  allocation_id = element(aws_eip.nats.*.id, count.index)

  tags = {
    Name = "${local.service_name}-${count.index + 1}"
  }
}

#####################
# Private Settings
#####################
resource "aws_subnet" "privates" {
  count = length(local.availablity_zones)

  vpc_id            = aws_vpc.default.id
  availability_zone = local.availablity_zones[count.index]
  cidr_block        = cidrsubnet(var.cidr, 8, (count.index + 1) * 10)

  tags = {
    "Name" = "${local.service_name}-private-${count.index + 1}"
  }
}
resource "aws_route_table" "privates" {
  count = length(local.availablity_zones)

  vpc_id = aws_vpc.default.id

  tags = {
    "Name" = "${local.service_name}-private-${count.index + 1}"
  }
}
resource "aws_route" "privates" {
  count = length(local.availablity_zones)

  destination_cidr_block = local.internet_cidr
  route_table_id         = element(aws_route_table.privates.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nats.*.id, count.index)

  depends_on = [aws_route_table.privates]
}
resource "aws_route_table_association" "privates" {
  count = length(local.availablity_zones)

  route_table_id = element(aws_route_table.privates.*.id, count.index)
  subnet_id      = element(aws_subnet.privates.*.id, count.index)

  depends_on = [aws_route.privates]
}

######################
# VPC EndPoint
######################
resource "aws_security_group" "vpc-ep" {
  name        = local.security_group_name
  description = local.security_group_name
  vpc_id      = aws_vpc.default.id

  tags = {
    "Name" = "${var.env}-VPCEndPoint-S3-security-Group"
  }

  lifecycle {
    ignore_changes = [name, description]
  }
}
resource "aws_security_group_rule" "vpc-ep-egress" {
  security_group_id = aws_security_group.vpc-ep.id

  type        = "egress"
  cidr_blocks = [local.internet_cidr]
  protocol    = "-1"
  from_port   = local.internet_port
  to_port     = local.internet_port
}
resource "aws_security_group_rule" "vpc-ep-ingress-443" {
  security_group_id = aws_security_group.vpc-ep.id

  type        = "ingress"
  cidr_blocks = [aws_vpc.default.cidr_block]
  protocol    = "tcp"
  from_port   = local.https_port
  to_port     = local.https_port
}
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.default.id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${var.env}-S3"
  }
}
resource "aws_vpc_endpoint_route_table_association" "s3s" {
  count = length(local.availablity_zones)

  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = element(aws_route_table.privates.*.id, count.index)
}
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-Docker-ECR"
  }
}
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-API-ECR"
  }
}
resource "aws_vpc_endpoint" "log" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-CloudWatch"
  }
}
resource "aws_vpc_endpoint" "events" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.events"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-CloudWatchEvents"
  }
}
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-SSM"
  }
}
resource "aws_vpc_endpoint" "ssm_ec2" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-SSM-EC2"
  }
}
resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-SSM-Messages"
  }
}
resource "aws_vpc_endpoint" "codedeploy" {
  vpc_id              = aws_vpc.default.id
  service_name        = "com.amazonaws.ap-northeast-1.codedeploy"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = tolist(aws_subnet.privates.*.id)
  security_group_ids  = [aws_security_group.vpc-ep.id]
  private_dns_enabled = true

  tags = {
    Name = "${var.env}-CodeDeploy"
  }
}
