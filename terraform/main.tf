terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name = "default-for-az"
    values = ["true"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "app" {
  name_prefix = "student-devops-app-"
  description = "Lab SSH and Flask access"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH from student IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }
  ingress {
    description = "Flask from student IP"
    from_port = 5000
    to_port = 5000
    protocol = "tcp"
    cidr_blocks = [var.web_cidr]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "student-devops-app-sg" }
}

resource "aws_instance" "app" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name = var.key_name
  subnet_id = sort(data.aws_subnets.default.ids)[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.app.id]
  tags = { Name = "student-devops-app" }
}
