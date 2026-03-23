provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "core" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "CoreVPC"
  }
}

resource "aws_vpc" "man" {
  cidr_block = "172.16.0.0/16"

  tags = {
    Name = "ManufacturingVPC"
  }
}

resource "aws_subnet" "core" {
  vpc_id     = aws_vpc.core.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "CoreSubnet"
  }
}

resource "aws_subnet" "perimeter" {
  vpc_id     = aws_vpc.core.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "PerimeterSubnet"
  }
}

resource "aws_subnet" "man" {
  vpc_id     = aws_vpc.man.id
  cidr_block = "172.16.0.0/24"

  tags = {
    Name = "ManufacturingSubnet"
  }
}

resource "aws_internet_gateway" "igw_core" {
  vpc_id = aws_vpc.core.id
}

resource "aws_internet_gateway" "igw_man" {
  vpc_id = aws_vpc.man.id
}

resource "aws_route_table" "core_rt" {
  vpc_id = aws_vpc.core.id
}

resource "aws_route_table" "man_rt" {
  vpc_id = aws_vpc.man.id
}

resource "aws_route_table_association" "core_assoc" {
  subnet_id      = aws_subnet.core.id
  route_table_id = aws_route_table.core_rt.id
}

resource "aws_route_table_association" "man_assoc" {
  subnet_id      = aws_subnet.man.id
  route_table_id = aws_route_table.man_rt.id
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = aws_vpc.core.id
  peer_vpc_id = aws_vpc.man.id
  auto_accept = true
}

# Routes for peering

resource "aws_route" "core_to_man" {
  route_table_id            = aws_route_table.core_rt.id
  destination_cidr_block    = "172.16.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "man_to_core" {
  route_table_id            = aws_route_table.man_rt.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


resource "aws_security_group" "sg_core" {
  vpc_id = aws_vpc.core.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_man" {
  vpc_id = aws_vpc.man.id

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "core_vm" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.core.id
  vpc_security_group_ids = [aws_security_group.sg_core.id]

  tags = {
    Name = "CoreVM"
  }
}

resource "aws_instance" "man_vm" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.man.id
  vpc_security_group_ids = [aws_security_group.sg_man.id]

  tags = {
    Name = "ManufacturingVM"
  }
}