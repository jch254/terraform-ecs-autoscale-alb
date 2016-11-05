provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "base_remote_state" {
  backend = "s3"
  config {
    bucket = "603-terraform-remote-state"
    key = "terraform-ecs-autoscale-alb/base-infra.tfstate"
    region = "${var.region}"
  }
}

module "alb_listener" {
  source = "./modules/alb-listener"

  service_name = "${var.service_name}"
  container_port = "${var.container_port}"
  vpc_id = "${data.terraform_remote_state.base_remote_state.vpc_id}"
  alb_listener_arn = "${data.terraform_remote_state.base_remote_state.alb_listener_arn}"
}

module "ecs_service" {
  source = "./modules/ecs-service"

  service_name = "${var.service_name}"
  docker_image = "${var.docker_image}"
  docker_tag = "${var.docker_tag}"
  container_cpu = "${var.container_cpu}"
  container_memory = "${var.container_memory}"
  container_port = "${var.container_port}"
  region = "${var.region}"
  cluster_name = "${data.terraform_remote_state.base_remote_state.cluster_name}"
  desired_count = "${var.min_capacity}"
  ecs_service_role_arn = "${data.terraform_remote_state.base_remote_state.ecs_service_role_arn}"
  target_group_arn = "${module.alb_listener.target_group_arn}"
}

module "autoscaling" {
  source = "./modules/autoscaling"

  service_name = "${var.service_name}"
  cluster_name = "${data.terraform_remote_state.base_remote_state.cluster_name}"
  ecs_service_autoscale_role_arn = "${data.terraform_remote_state.base_remote_state.ecs_service_autoscale_role_arn}"
  min_capacity = "${var.min_capacity}"
  max_capacity = "${var.max_capacity}"
}
