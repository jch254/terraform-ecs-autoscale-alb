# Launch configuration for each bastion
resource "aws_launch_configuration" "bastion" {
  name_prefix = "bastion-"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_pair_name}"
  associate_public_ip_address = true
  image_id = "${var.ami}"

  security_groups = [
    "${var.security_group_internal_id}",
    "${var.security_group_ssh_id}",
  ]

  # Important note: whenever using a launch configuration with an auto scaling
  # group, you must set create_before_destroy = true. However, as soon as you
  # set create_before_destroy = true in one resource, you must also set it in
  # every resource that it depends on, or we'll get an error about cyclic
  # dependencies (especially when removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle { create_before_destroy = true }
}

# Autoscaling group that specifies how we want to scale the bastions
resource "aws_autoscaling_group" "bastion" {
  name = "bastion"
  min_size = "1"
  max_size = "1"
  launch_configuration = "${aws_launch_configuration.bastion.name}"
  vpc_zone_identifier = ["${split(",", var.bastion_subnet_ids)}"]
  health_check_type = "EC2"

  lifecycle { create_before_destroy = true }

  tag {
    key = "Name"
    value = "bastion"
    propagate_at_launch = true
  }
}
