terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_ebs_volume" "lab_disk1" {
  availability_zone = "eu-central-1a"
  size              = 32
  type              = "standard"

  tags = {
    Name = "lab03-disk1"
  }
}

resource "aws_ebs_volume" "lab_disk2" {
  availability_zone = "eu-central-1a"
  size              = 32
  type              = "standard"

  tags = {
    Name = "lab03-disk2"
  }
}
resource "aws_ebs_volume" "lab_disk3" {
  availability_zone = "eu-central-1a"
  size              = 32
  type              = "standard"

  tags = {
    Name = "lab03-disk3"
  }
}
resource "aws_ebs_volume" "lab_disk4" {
  availability_zone = "eu-central-1a"
  size              = 32
  type              = "standard"

  tags = {
    Name = "lab03-disk4"
  }
}
resource "aws_ebs_volume" "lab_disk5" {
  availability_zone = "eu-central-1a"
  size              = 32
  type              = "standard"

  tags = {
    Name = "lab03-disk5"
  }
}