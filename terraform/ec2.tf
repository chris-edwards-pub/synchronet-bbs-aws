data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "sbbs" {
  key_name   = "sbbs"
  public_key = file("~/.ssh/id_ed25519.pub")
  
  lifecycle {
    create_before_destroy = true
  }
}

# Elastic IP for consistent public IP address
resource "aws_eip" "sbbs_eip" {
  domain = "vpc"
  
  tags = {
    Name        = "${var.project_name}-sbbs-eip"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.main]
}

# Associate Elastic IP with the instance
resource "aws_eip_association" "sbbs_eip_assoc" {
  instance_id   = aws_instance.sbbs_server.id
  allocation_id = aws_eip.sbbs_eip.id
}

resource "aws_instance" "sbbs_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type         = "t3.micro"
  key_name              = aws_key_pair.sbbs.key_name
  vpc_security_group_ids = [aws_security_group.sbbs.id]
  subnet_id             = aws_subnet.public.id

  tags = {
    Name = "${var.project_name}-sbbs-server"
    Environment = var.environment
    Backup = "true"
  }

  # Force recreation when key changes
  user_data = base64encode("echo 'Key: ${aws_key_pair.sbbs.key_name}'")
}

resource "aws_security_group" "sbbs" {
  name_prefix = "${var.project_name}-"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
  }

  ingress {
    from_port   = 23
    to_port     = 23
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  # MQTT port for Synchronet BBS monitoring
  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MQTT WebSocket port for Synchronet BBS web interface
  ingress {
    from_port   = 1884
    to_port     = 1884
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MQTT TLS port for secure connections
  ingress {
    from_port   = 8883
    to_port     = 8883
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MQTT WebSocket TLS port for secure web interface
  ingress {
    from_port   = 8884
    to_port     = 8884
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
