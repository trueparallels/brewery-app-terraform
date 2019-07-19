resource "aws_subnet" "brewery-app-subnet" {
  vpc_id = "${var.brewery_app_vpc_id}"
  cidr_block = "172.31.100.0/20"

  tags = {
    Name = "brewery-app-subnet"
  }
}
