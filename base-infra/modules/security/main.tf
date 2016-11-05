# Security group allowing internal traffic (inside VPC)
resource "aws_security_group" "internal" {
  vpc_id = "${var.vpc_id}"
  name = "internal"
  description = "Allow internal traffic"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "internal"
  }
}

# Security group allowing SSH traffic from a designated IP address (var.ssh_allowed_ip)
resource "aws_security_group" "ssh" {
  vpc_id = "${var.vpc_id}"
  name = "ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.ssh_allowed_ip}/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ssh"
  }
}

# Security group allowing inbound HTTPS from anywhere
resource "aws_security_group" "inbound" {
  vpc_id = "${var.vpc_id}"
  name = "inbound"
  description = "Allow inbound HTTPS traffic"

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "inbound"
  }
}

# An IAM instance profile we attach to the EC2 instances in the cluster
resource "aws_iam_instance_profile" "ecs_instance" {
  name = "ecs-instance"
  roles = ["${aws_iam_role.ecs_instance.name}"]

  lifecycle { create_before_destroy = true }
}

# An IAM role that we attach to the EC2 Instances in the cluster
resource "aws_iam_role" "ecs_instance" {
  name = "ecs-instance"
  assume_role_policy = "${file("${path.module}/policies/ecs-instance.json")}"

  lifecycle { create_before_destroy = true }
}

# IAM policy we add to ECS cluster instances that allows them to do their thing
resource "aws_iam_role_policy" "ecs_instance_policy" {
  name = "ecs-instance-policy"
  role = "${aws_iam_role.ecs_instance.id}"
  policy = "${file("${path.module}/policies/ecs-instance-policy.json")}"

  lifecycle { create_before_destroy = true }
}

# An IAM Role that we attach to ECS services
resource "aws_iam_role" "ecs_service" {
  name = "ecs-service"
  assume_role_policy = "${file("${path.module}/policies/ecs-service.json")}"
}

# Managed IAM Policy for ECS services to communicate with EC2 Instances
resource "aws_iam_role_policy_attachment" "ecs_service" {
  role = "${aws_iam_role.ecs_service.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

# An IAM Role for ECS service autoscaling
resource "aws_iam_role" "ecs_service_autoscale" {
  name = "ecs-service-autoscale"
  assume_role_policy = "${file("${path.module}/policies/ecs-service-autoscale.json")}"
}

# Managed IAM Policy for ECS service autoscaling
resource "aws_iam_role_policy_attachment" "ecs_service_autoscale" {
  role = "${aws_iam_role.ecs_service_autoscale.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceAutoscaleRole"
}
