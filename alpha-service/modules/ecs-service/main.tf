resource "aws_cloudwatch_log_group" "alpha_service_lg" {
  name = "${var.service_name}"
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/task-definition.json")}"

  vars {
    service_name = "${var.service_name}"
    docker_image = "${var.docker_image}"
    docker_tag = "${var.docker_tag}"
    container_cpu = "${var.container_cpu}"
    container_memory = "${var.container_memory}"
    container_port = "${var.container_port}"
    log_group_name = "${aws_cloudwatch_log_group.alpha_service_lg.name}"
    log_group_region = "${var.region}"
  }
}

# The ECS task that specifies what Docker containers we need to run the service
resource "aws_ecs_task_definition" "alpha_service" {
  family = "${var.service_name}"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

# A long-running ECS service for the alpha_service task
resource "aws_ecs_service" "alpha_service" {
  name = "${var.service_name}"
  cluster = "${var.cluster_name}"
  task_definition = "${aws_ecs_task_definition.alpha_service.arn}"
  desired_count = "${var.desired_count}"
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 100
  iam_role = "${var.ecs_service_role_arn}"

  load_balancer {
    target_group_arn = "${var.target_group_arn}"
    container_name = "${var.service_name}"
    container_port = "${var.container_port}"
  }
}
