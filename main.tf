terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
  }
  required_version = ">= 0.14.9"
}

locals {
  port_http  = 80
  port_https = 443
  port_mysql = 3306
  port_ssh   = 23
}

data "aws_vpc" "default_vpc_data" {
  default = true
}

data "aws_subnet" "default_subnet" {
  id     = "subnet-01b070082b1e55229"
  vpc_id = data.aws_vpc.default_vpc_data.id
}

provider "aws" {
  region  = "ap-south-1"
  profile = "default"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_security_group" "instance_security_group" {
  name   = "allow_ec2_instance_mysql"
  vpc_id = data.aws_vpc.default_vpc_data.id

  ingress {
    from_port        = local.port_mysql
    to_port          = local.port_mysql
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = local.port_ssh
    to_port          = local.port_ssh
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = local.port_https
    to_port          = local.port_https
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = local.port_http
    to_port          = local.port_http
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "database_security_group_rds" {
  name = "rds-ec2-sg"

  ingress {
    from_port       = 3306
    protocol        = "tcp"
    to_port         = 3306
    security_groups = [aws_security_group.instance_security_group.id]
  }

}


resource "aws_instance" "ec2_instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "Incubyte-key"
  subnet_id       = data.aws_subnet.default_subnet.id
  security_groups = [aws_security_group.instance_security_group.id]
}


resource "aws_db_instance" "pokemon_db" {
  identifier             = "pokemon-db"
  db_name                = "pokemon"
  engine                 = "mariadb"
  engine_version         = "10.6.11"
  instance_class         = "db.t2.micro"
  allocated_storage      = 20
  username               = "admin"
  password               = "my_cool_secret"
  skip_final_snapshot    = true
  port                   = 3306
  publicly_accessible    = false
  availability_zone      = "ap-south-1a"
  vpc_security_group_ids = [aws_security_group.database_security_group_rds.id]
}