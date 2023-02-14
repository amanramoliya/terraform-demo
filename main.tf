terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.5.0"
    }
  }
  required_version = ">= 0.14.9"
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


module "ec2" {
  source = "./ec2"

  subnet_id = data.aws_subnet.default_subnet.id
  vpc_id    = data.aws_vpc.default_vpc_data.id
}

module "rds" {
  source      = "./rds"
  instance_sg = module.ec2.ec2-sg
}




