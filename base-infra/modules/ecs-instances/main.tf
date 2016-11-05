# User data template that specifies how to bootstrap each instance
data "template_file" "user_data" {
  template = "${file("${path.module}/user-data.tpl")}"

  vars {
    cluster_name = "${var.cluster_name}"
    dd_agent_task_name = "${var.dd_agent_task_name}"
    hello_world_task_name = "${var.hello_world_task_name}"
  }
}

# The launch configuration for each EC2 Instance that will run in the cluster
resource "aws_launch_configuration" "ecs_instance" {
  name_prefix = "${var.cluster_name}-instance-"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_pair_name}"
  iam_instance_profile = "${var.instance_profile_name}"
  security_groups = ["${var.security_group_ecs_instance_id}"]
  image_id = "${var.ami}"
  user_data = "${data.template_file.user_data.rendered}"

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

# The auto scaling group that specifies how we want to scale the number of EC2 Instances in the cluster
resource "aws_autoscaling_group" "ecs_cluster" {
  name = "${var.cluster_name}-instances"
  min_size = "${var.asg_min}"
  max_size = "${var.asg_max}"
  launch_configuration = "${aws_launch_configuration.ecs_instance.name}"
  vpc_zone_identifier = ["${split(",", var.ecs_cluster_subnet_ids)}"]
  health_check_type = "EC2"
  target_group_arns = ["${var.target_group_arn}"]

  lifecycle { create_before_destroy = true }

  tag {
    key = "Name"
    value = "${var.cluster_name}-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "scale_up" {
  name = "${var.cluster_name}-instances-scale-up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs_cluster.name}"
}

resource "aws_autoscaling_policy" "scale_down" {
  name = "${var.cluster_name}-instances-scale-down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.ecs_cluster.name}"
}

# A CloudWatch alarm that monitors CPU utilization of cluster instances for scaling up
resource "aws_cloudwatch_metric_alarm" "ecs_cluster_instances_cpu_high" {
  alarm_name = "${var.cluster_name}-instances-CPU-Utilization-Above-80"
  alarm_description = "This alarm monitors ${var.cluster_name} instances CPU utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "80"
  alarm_actions = ["${aws_autoscaling_policy.scale_up.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs_cluster.name}"
  }
}

# A CloudWatch alarm that monitors CPU utilization of cluster instances for scaling down
resource "aws_cloudwatch_metric_alarm" "ecs_cluster_instances_cpu_low" {
  alarm_name = "${var.cluster_name}-instances-CPU-Utilization-Below-5"
  alarm_description = "This alarm monitors ${var.cluster_name} instances CPU utilization for scaling down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "5"
  alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs_cluster.name}"
  }
}

# A CloudWatch alarm that monitors memory utilization of cluster instances for scaling up
resource "aws_cloudwatch_metric_alarm" "ecs_cluster_instances_memory_high" {
  alarm_name = "${var.cluster_name}-instances-Memory-Utilization-Above-80"
  alarm_description = "This alarm monitors ${var.cluster_name} instances memory utilization for scaling up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "1"
  metric_name = "MemoryUtilization"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "80"
  alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs_cluster.name}"
  }
}

# A CloudWatch alarm that monitors memory utilization of cluster instances for scaling down
resource "aws_cloudwatch_metric_alarm" "ecs_cluster_instances_memory_low" {
  alarm_name = "${var.cluster_name}-instances-Memory-Utilization-Below-5"
  alarm_description = "This alarm monitors ${var.cluster_name} instances memory utilization for scaling down"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "1"
  metric_name = "MemoryUtilization"
  namespace = "AWS/EC2"
  period = "300"
  statistic = "Average"
  threshold = "5"
  alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.ecs_cluster.name}"
  }
}
