provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "lab9_vpc" {
  cidr_block = "10.90.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id            = aws_vpc.lab9_vpc.id
  cidr_block        = "10.90.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet2" {
  vpc_id            = aws_vpc.lab9_vpc.id
  cidr_block        = "10.90.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab9_vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.lab9_vpc.id
}

resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.lab9_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "prod" {
  name_prefix   = "lab9-prod"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
echo "<h1>PRODUCTION $(hostname)</h1>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
EOF
  )
}

resource "aws_launch_template" "staging" {
  name_prefix   = "lab9-staging"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg.id]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
yum install -y httpd
echo "<h1>STAGING $(hostname)</h1>" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
EOF
  )
}

resource "aws_lb_target_group" "prod_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab9_vpc.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "staging_tg" {
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.lab9_vpc.id

  health_check {
    path = "/"
  }
}

resource "aws_lb" "alb" {
  name               = "lab9-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_groups    = [aws_security_group.sg.id]
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.staging_tg.arn
  }
}

resource "aws_autoscaling_group" "prod_asg" {
  desired_capacity = 2
  min_size         = 1
  max_size         = 3

  vpc_zone_identifier = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  launch_template {
    id      = aws_launch_template.prod.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.prod_tg.arn]
}

resource "aws_autoscaling_group" "staging_asg" {
  desired_capacity = 1
  min_size         = 1
  max_size         = 2

  vpc_zone_identifier = [
    aws_subnet.subnet1.id,
    aws_subnet.subnet2.id
  ]

  launch_template {
    id      = aws_launch_template.staging.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.staging_tg.arn]
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}