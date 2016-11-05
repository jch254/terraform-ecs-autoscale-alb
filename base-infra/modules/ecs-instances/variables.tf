variable "cluster_name" {
  description = "Name of ECS cluster"
}

variable "dd_agent_task_name" {
  description = "Name of Datadog agent ECS task"
}

variable "hello_world_task_name" {
  description = "Name of 'hello world' ECS task"
}

variable "instance_type" {
  description = "Instance type of each EC2 instance in the ECS cluster"
}

variable "key_pair_name" {
  description = "Name of the Key Pair that can be used to SSH to each EC2 instance in the ECS cluster"
}

variable "instance_profile_name" {
  description = "Name of IAM instance profile for ECS instances"
}

variable "security_group_ecs_instance_id" {
  description = "Id of security group allowing internal traffic"
}

variable "ami" {
  description = "AMI of each EC2 instance in the ECS cluster"
}

variable "asg_min" {
  description = "Minimum number of EC2 instances to run in the ECS cluster"
}

variable "asg_max" {
  description = "Maximum number of EC2 instances to run in the ECS cluster"
}

variable "ecs_cluster_subnet_ids" {
  description = "Comma-separated list of subnets where EC2 instances should be deployed"
}

variable "target_group_arn" {
  default = "ALB Target group ARN"
}
