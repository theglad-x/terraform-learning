provider "aws" {
    region = "us-east-1" 
}

variable "subnet_cidr_block" {
  description = "subnet cidr block"
}

variable "vpc_cidr_block" {
    description = "vpc cidr block"
}

variable "environment" {
    description = "deploment environment" 
}


resource "aws_vpc" "dev-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = var.environment
        vpc_env: "first"
    }
}

resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.dev-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "us-east-1a"
    tags = {
        Name = "dev-subnet-1"
    }
}

data "aws_vpc" "existing-vpc" {
    default = true
}

resource "aws_subnet" "dev-subnet-2" {
    vpc_id = data.aws_vpc.existing-vpc.id
    cidr_block = "172.31.96.0/20"
    availability_zone = "us-east-1b"
    tags = {
      Name = "dev-subnet-2"
    }
}

output "dev-vpc-id" {
  value = aws_vpc.dev-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.dev-subnet-1.id
}
