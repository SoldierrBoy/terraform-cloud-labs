provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "core" {
  cidr_block = "10.20.0.0/16"

  tags = {
    Name = "CoreServicesVnet"
  }
}

resource "aws_subnet" "shared" {
  vpc_id     = aws_vpc.core.id
  cidr_block = "10.20.10.0/24"

  tags = {
    Name = "SharedServicesSubnet"
  }
}

resource "aws_subnet" "database" {
  vpc_id     = aws_vpc.core.id
  cidr_block = "10.20.20.0/24"

  tags = {
    Name = "DatabaseSubnet"
  }
}

resource "aws_vpc" "manufacturing" {
  cidr_block = "10.30.0.0/16"

  tags = {
    Name = "ManufacturingVnet"
  }
}

resource "aws_subnet" "sensor1" {
  vpc_id     = aws_vpc.manufacturing.id
  cidr_block = "10.30.20.0/24"

  tags = {
    Name = "SensorSubnet1"
  }
}

resource "aws_subnet" "sensor2" {
  vpc_id     = aws_vpc.manufacturing.id
  cidr_block = "10.30.21.0/24"

  tags = {
    Name = "SensorSubnet2"
  }
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.core.id
  peer_vpc_id   = aws_vpc.manufacturing.id
  auto_accept   = true

  tags = {
    Name = "Core-to-Manufacturing"
  }
}


resource "aws_security_group" "sg" {
  name   = "myNSGSecure"
  vpc_id = aws_vpc.core.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress = []
}

