resource "aws_subnet" "brewery-app-subnet" {
  vpc_id = var.brewery_app_vpc_id
  cidr_block = "172.31.96.0/20"

  tags = {
    Name = "brewery-app-subnet"
  }
}

resource "aws_subnet" "brewery-app-subnet-two" {
  vpc_id = var.brewery_app_vpc_id
  cidr_block = "172.31.112.0/20"

  tags = {
    Name = "brewery-app-subnet-two"
  }
}

resource "aws_security_group" "allow-http-traffic" {
  name = "allow-http-traffic"
  vpc_id = var.brewery_app_vpc_id

  ingress {
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  ingress {
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "-1"
  }
}
