output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc.cidr_block}"
}

output "subnet_private_ids" {
  value = "${join(",", aws_subnet.private_subnet.*.id)}"
}

output "subnet_public_ids" {
  value = "${join(",", aws_subnet.public_subnet.*.id)}"
}
