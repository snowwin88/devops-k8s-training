resource "aws_security_group" "web" {
  name        = "terraform-web-sg"
  description = "Allow SSH and HTTP for Terraform EC2 practice"
  vpc_id      = "vpc-063a31df6f17b1818"

  ingress {
    description = "Allow SSH from internet for practice"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # For practice only.
    # Better: replace 0.0.0.0/0 with your own public IP /32.
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP from internet for practice"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "terraform-web-sg"
    ManagedBy = "terraform"
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = "t3.micro"
  subnet_id                   = "subnet-0e56a8ce49700ee9f"
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  key_name = "devops-practice-key"

  user_data = <<-EOF
              #!/bin/bash
              dnf update -y
              dnf install -y nginx
              systemctl enable nginx
              systemctl start nginx
              echo "Hello from Terraform EC2" > /usr/share/nginx/html/index.html
              EOF

  tags = {
    Name      = "terraform-web-ec2"
    ManagedBy = "terraform"
  }
}
