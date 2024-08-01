provider "aws" {
  region = "us-east-1"
}

variable "vpc-cidr-block" {}
variable "subnet-cidr-blocks" {}
variable "a-zone" {}
variable "env-prefix" {}
variable "my-ip" {}
variable "instance-type" {}
variable "my-public-key" {}

resource "aws_vpc" "mydev-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name = "${var.env-prefix}-vpc"
  }
}

resource "aws_subnet" "mydev-subnet-1" {
  cidr_block        = var.subnet-cidr-blocks[0]
  vpc_id            = aws_vpc.mydev-vpc.id
  availability_zone = var.a-zone[0]
  tags = {
    Name = "${var.env-prefix}-subnet-1"
  }
}

resource "aws_route_table" "mydev-route-able" {
  vpc_id = aws_vpc.mydev-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mydev-igw.id
  }
  tags = {
    Name = "${var.env-prefix}-rtb"
  }
}

resource "aws_internet_gateway" "mydev-igw" {
  vpc_id = aws_vpc.mydev-vpc.id
  tags = {
    Name = "${var.env-prefix}-igw"
  }
}


resource "aws_route_table_association" "mydev-rtb-subnet" {
  subnet_id      = aws_subnet.mydev-subnet-1.id
  route_table_id = aws_route_table.mydev-route-able.id
}

resource "aws_security_group" "mydev-sg" {
  name   = "mydev-sg"
  vpc_id = aws_vpc.mydev-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my-ip]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my-ip]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env-prefix}-sg"
  }
}

data "aws_ami" "latest-ubuntu-image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3*"]
  }
}

output "aws_ami" {
  value = data.aws_ami.latest-ubuntu-image.id
}

output "ec2_public_ip" {
  value = data.aws_instance.mydev-server.public_ip
}

resource "aws_key_pair" "tf-ssh-key-pair" {
  key_name   = "glad-keypair"
  public_key = file(var.my-public-key)
}

resource "aws_instance" "mydev-server" {
  ami           = data.aws_ami.latest-ubuntu-image.id
  instance_type = var.instance-type

  subnet_id              = aws_subnet.mydev-subnet-1.id
  vpc_security_group_ids = [aws_security_group.mydev-sg.id]
  availability_zone      = var.a-zone[0]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.tf-ssh-key-pair.key_name

  user_data = file(user-data-script.sh)
  tags = {
    Name = "${var.env-prefix}-server"
  }
}
