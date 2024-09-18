provider "aws" {
  region = var.region
}

#VPC

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    "Name" = "MainVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zones[0]

  tags = {
    "Name" = "PublicSubnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zones[1]

  tags = {
    "Name" = "PrivateSubnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "IgwMain"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    "Name" = "MainVpcRouteTable"
  }
}

resource "aws_route_table_association" "assoc" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {

  subnet_id     = aws_subnet.private_subnet.id
  allocation_id = aws_eip.nat_eip.id

  depends_on = [aws_internet_gateway.igw]

  tags = {
    "Name" = "NatGatewayMain"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    "Name" = "PrivateRT"
  }
}

resource "aws_route_table_association" "private_assoc" {
  route_table_id = aws_route_table.private_rt.id
  subnet_id      = aws_subnet.private_subnet.id
}

#SECURITY GROUP

resource "aws_security_group" "web-sg" {
  name = "main_vpc_sg"

  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "WEBsg"
  }
}

resource "aws_security_group_rule" "port-80" {
  type              = "ingress"
  security_group_id = aws_security_group.web-sg.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "port-443" {
  type              = "ingress"
  security_group_id = aws_security_group.web-sg.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group_rule" "port-22" {
  type              = "ingress"
  security_group_id = aws_security_group.web-sg.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks = [
    "your ip"
  ]
}

resource "aws_security_group_rule" "port-web-0" {
  type              = "egress"
  security_group_id = aws_security_group.web-sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
}

resource "aws_security_group" "db-sg" {
  name = "db_vpc_sg"

  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "DBsg"
  }
}

resource "aws_security_group_rule" "port-3306" {
  security_group_id        = aws_security_group.db-sg.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web-sg.id
}

resource "aws_security_group_rule" "port-db-0" {
  security_group_id = aws_security_group.db-sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}


#INSTANCE

resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = var.key_name

  security_groups             = [aws_security_group.web-sg.id]
  associate_public_ip_address = true

  provisioner "remote-exec" {
    script = "provisioners/setup.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/generic-key.pem")
      host        = self.public_ip
    }
  }

  tags = {
    "Name" = "WebServer"
  }
}


