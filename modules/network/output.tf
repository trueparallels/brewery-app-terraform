output "brewery_app_subnet_id" {
  value = "${aws_subnet.brewery-app-subnet.id}"
}

output "brewery-app-sg-allow_http" {
  value = "${aws_security_group.allow-http-traffic.id}"
}