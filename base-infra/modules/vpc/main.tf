# VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "vpc"
  }
}

# Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "igw"
  }
}

# Public subnets
# These will get a 0/0 route to the IGW gateway as below
# The az_count variable determines how many subnets will be created
resource "aws_subnet" "public_subnet" {
  count = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = "${element(split(",", lookup(var.availability_zones, var.region)), count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "Public-subnet-${count.index + 1}"
  }
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
      Name = "public-rt"
  }
}

# Attach a 0/0 route to the public route table going to the IGW
resource "aws_route" "internet" {
  route_table_id = "${aws_route_table.public_rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"

  depends_on = ["aws_internet_gateway.igw", "aws_route_table.public_rt"]
}

# Public subnet route table associations
# The az_count variable determines how many associations will be created (one per public subnet)
resource "aws_route_table_association" "public" {
  count = "${var.az_count}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

# The public route needs to be the default one (so that the default
# route on the VPC goes to the IGW).
resource "aws_main_route_table_association" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

# NAT gateway elastic IPs
# The az_count variable determines how many EIPs will be created (one per private subnet)
resource "aws_eip" "nat_gateway" {
  count = "${var.az_count}"
  vpc = true
}

# NAT gateways
# The az_count variable determines how many NAT gateways will be created (one per public subnet)
resource "aws_nat_gateway" "nat_gateway" {
  count = "${var.az_count}"
  allocation_id = "${element(aws_eip.nat_gateway.*.id, count.index)}"
  subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  depends_on = ["aws_internet_gateway.igw", "aws_eip.nat_gateway"]
}

# Private subnets
# The az_count variable determines how many subnets will be created
resource "aws_subnet" "private_subnet" {
  count = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.${100 + count.index}.0/24"
  availability_zone = "${element(split(",", lookup(var.availability_zones, var.region)), count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name = "Private-subnet-${count.index + 1}"
  }
}

# Private route tables
# The az_count variable determines how many route tables will be created
# To get around the single-AZ nature of the current NAT Gateway implementation,
# we define a route table per AZ
resource "aws_route_table" "private_rt" {
  count = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
      Name = "private-rt"
  }
}

# Attach 0/0 route to private route tables going to the NAT gateways
resource "aws_route" "nat" {
  count = "${var.az_count}"
  route_table_id = "${element(aws_route_table.private_rt.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
}

# Associate the private route tables with the private subnets
resource "aws_route_table_association" "private" {
  count = "${var.az_count}"
  subnet_id = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private_rt.*.id, count.index)}"
}
