resource "aws_vpc" "practice" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name      = "terraform-practice-vpc"
    ManagedBy = "terraform"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.practice.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name      = "terraform-public-subnet-1"
    ManagedBy = "terraform"
  }
}

resource "aws_internet_gateway" "practice" {
  vpc_id = aws_vpc.practice.id

  tags = {
    Name      = "terraform-practice-igw"
    ManagedBy = "terraform"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.practice.id

  tags = {
    Name      = "terraform-public-rt"
    ManagedBy = "terraform"
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.practice.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "web" {
  name        = "terraform-vpc-web-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.practice.id

  ingress {
    description = "SSH for practice"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # Better: use your public IP /32
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP for practice"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "terraform-vpc-web-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "Hello from Terraform custom VPC" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name      = "terraform-vpc-web-ec2"
    ManagedBy = "terraform"
  }
}
