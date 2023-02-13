terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
  }
  required_version = ">= 0.14.9"
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


resource "aws_instance" "ec2_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "Incubyte-key"
}

resource "aws_db_instance" "incubyte_db" {
  identifier          = "incubyte-db"
  db_name             = "pokemon"
  engine              = "mariadb"
  engine_version      = "10.6.11"
  instance_class      = "db.t2.micro"
  allocated_storage   = 20
  username            = "admin"
  password            = "my_cool_secret"
  skip_final_snapshot = true
  port                = 3306
  publicly_accessible = false
}