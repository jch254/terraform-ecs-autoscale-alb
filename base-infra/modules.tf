# Configure the AWS Provider
provider "aws" {
  region = "${var.region}"
}

module "vpc" {
  source = "./modules/vpc"

  region = "${var.region}"
  az_count = "${var.az_count}"
}

module "security" {
  source = "./modules/security"

  vpc_id = "${module.vpc.vpc_id}"
  vpc_cidr_block = "${module.vpc.vpc_cidr_block}"
  ssh_allowed_ip = "${var.ssh_allowed_ip}"
}

module "bastion" {
  source = "./modules/bastion"

  instance_type = "${var.bastion_instance_type}"
  key_pair_name = "${var.bastion_key_pair_name}"
  security_group_internal_id = "${module.security.internal_id}"
  security_group_ssh_id = "${module.security.ssh_id}"
  ami = "${lookup(var.bastion_ami, var.region)}"
  bastion_subnet_ids = "${module.vpc.subnet_public_ids}"
}

module "alb" {
  source = "./modules/alb"

  security_group_internal_id = "${module.security.internal_id}"
  security_group_inbound_id = "${module.security.inbound_id}"
  alb_subnet_ids = "${module.vpc.subnet_public_ids}"
  vpc_id = "${module.vpc.vpc_id}"
  acm_arn = "${var.acm_arn}"
  route53_zone_id = "${var.route53_zone_id}"
  alb_dns_name = "${var.alb_dns_name}"
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cluster_name = "${var.cluster_name}"
  datadog_api_key = "${var.datadog_api_key}"
}

module "ecs_instances" {
  source = "./modules/ecs-instances"

  cluster_name = "${module.ecs_cluster.cluster_name}"
  dd_agent_task_name = "${module.ecs_cluster.dd_agent_task_name}"
  hello_world_task_name = "${module.ecs_cluster.hello_world_task_name}"
  instance_type = "${var.instance_type}"
  key_pair_name = "${var.key_pair_name}"
  instance_profile_name = "${module.security.ecs_instance_profile_name}"
  security_group_ecs_instance_id = "${module.security.internal_id}"
  ami = "${lookup(var.ami, var.region)}"
  asg_min = "${var.asg_min}"
  asg_max = "${var.asg_max}"
  ecs_cluster_subnet_ids = "${module.vpc.subnet_private_ids}"
  target_group_arn = "${module.alb.target_group_arn}"
}
