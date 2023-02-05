# Create VPC

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "tito-vpc"
  }
}

# Create Internet Gateway

resource "aws_internet_gateway" "inter-gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "tito-internet-gateway"
  }
}

# Create public Route Table

resource "aws_route_table" "tito" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.inter-gateway.id
  }

  tags = {
    Name = "tito"
  }
}

# Associate public subnet 1 with public route table

resource "aws_route_table_association" "tito-subnet1-association" {
  subnet_id      = aws_subnet.tito-subnet1.id
  route_table_id = aws_route_table.tito.id
}

# Associate public subnet 2 with public route table

resource "aws_route_table_association" "tito-subnet2-association" {
  subnet_id      = aws_subnet.tito-subnet2.id
  route_table_id = aws_route_table.tito.id
}

# Associate public subnet 3 with public route table

resource "aws_route_table_association" "tito-subnet3-association" {
  subnet_id      = aws_subnet.tito-subnet3.id
  route_table_id = aws_route_table.tito.id
}


# Create Public Subnet-1

resource "aws_subnet" "tito-subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "tito-subnet1"
  }
}

# Create Public Subnet-2

resource "aws_subnet" "tito-subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "tito-subnet2"
  }
}

# Create Public Subnet-3

resource "aws_subnet" "tito-subnet3" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"
  tags = {
    Name = "tito-subnet3"
  }
}

# Create a security group for the load balancer

resource "aws_security_group" "tito-load_balancer_sg" {
  name        = "load-balancer-sg"
  description = "Security group for the load balancer"
  vpc_id      = aws_vpc.main.id

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

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create Security Group to allow port 22, 80 and 443

resource "aws_security_group" "tito-security-grp-rule" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP and HTTPS inbound traffic for private instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tito-load_balancer_sg.id]
  }

  ingress {
    description     = "HTTPS"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.tito-load_balancer_sg.id]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "allow_ssh_http_https_tito"
  }
}

# # Create a instance1

resource "aws_instance" "tito-instance1" {
  ami               = "ami-0778521d914d23bc1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = "titokey"
  subnet_id         = aws_subnet.tito-subnet1.id
  security_groups   = [aws_security_group.tito-security-grp-rule.id]
  tags = {
    Name = "instance1-tito"
  }
  
}

# # Create a instance2

resource "aws_instance" "tito-instance2" {
  ami               = "ami-0778521d914d23bc1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1b"
  key_name          = "titokey"
  subnet_id         = aws_subnet.tito-subnet2.id
  security_groups   = [aws_security_group.tito-security-grp-rule.id]
  tags = {
    Name = "instance2-tito"
  }
}

# # Create a instance3

resource "aws_instance" "tito-instance3" {
  ami               = "ami-0778521d914d23bc1"
  instance_type     = "t2.micro"
  availability_zone = "us-east-1c"
  key_name          = "titokey"
  subnet_id         = aws_subnet.tito-subnet3.id
  security_groups   = [aws_security_group.tito-security-grp-rule.id]
  tags = {
    Name = "instance3-tito"
  }
}

# # Create an Application Load Balancer

resource "aws_lb" "tito-load-balancer" {
  name            = "loadbalancer-tito"
  internal        = false
  security_groups = [aws_security_group.tito-load_balancer_sg.id]
  subnets         = [aws_subnet.tito-subnet1.id, aws_subnet.tito-subnet2.id, aws_subnet.tito-subnet3.id]

  enable_deletion_protection = false
  depends_on                 = [aws_instance.tito-instance1, aws_instance.tito-instance2, aws_instance.tito-instance3]
}

# # Create the target group

resource "aws_lb_target_group" "tito-target-group" {
  name     = "target-group-tito"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# # Create the listener

resource "aws_lb_listener" "tito-listener" {
  load_balancer_arn = aws_lb.tito-load-balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tito-target-group.arn
  }
}

# # Create the listener rule

resource "aws_lb_listener_rule" "tito-listener-rule" {
  listener_arn = aws_lb_listener.tito-listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tito-target-group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}


# # Attach the target group to the load balancer

resource "aws_lb_target_group_attachment" "target-group-attachment-tito1" {
  target_group_arn = aws_lb_target_group.tito-target-group.arn
  target_id        = aws_instance.tito-instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target-group-attachment-tito2" {
  target_group_arn = aws_lb_target_group.tito-target-group.arn
  target_id        = aws_instance.tito-instance2.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "target-group-attachment-tito3" {
  target_group_arn = aws_lb_target_group.tito-target-group.arn
  target_id        = aws_instance.tito-instance3.id
  port             = 80
}

resource "local_file" "Ip_file" {
  filename = "/mnt/c/Users/user/Desktop/TECH LIFE/3RD SEMESTER/Terraform/host_inventory"
  content  = <<EOT
${aws_instance.tito-instance1.public_ip}
${aws_instance.tito-instance2.public_ip}
${aws_instance.tito-instance3.public_ip}
  EOT
}

# # Route 53 and sub-domain name setup

resource "aws_route53_zone" "domain-name" {
  name = "terraform-test.bolasto.me"

  tags = {
    Environment = "domain-name"
  }
}

resource "aws_route53_record" "record" {
  zone_id = aws_route53_zone.domain-name.zone_id
  name    = "terraform-test.bolasto.me"
  type    = "A"

  alias {
    name                   = aws_lb.tito-load-balancer.dns_name
    zone_id                = aws_lb.tito-load-balancer.zone_id
    evaluate_target_health = true
  }
  depends_on = [
    aws_lb.tito-load-balancer
  ]
}
