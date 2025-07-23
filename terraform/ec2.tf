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
}

resource "aws_instance" "sbbs_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type         = "t2.micro"
  key_name              = aws_key_pair.sbbs.key_name
  vpc_security_group_ids = [aws_security_group.sbbs.id]
  subnet_id             = aws_subnet.public.id

  tags = {
    Name = "${var.project_name}-sbbs-server"
  }
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
