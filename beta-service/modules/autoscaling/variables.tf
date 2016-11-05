variable "service_name" {
  description = "Name of service"
}

variable "cluster_name" {
  description = "Name of ECS cluster"
}

variable "ecs_service_autoscale_role_arn" {
  description = "ARN of IAM role for ECS service autoscaling"
}

variable "min_capacity" {
  description = "Minimum number of containers to run"
}

variable "max_capacity" {
  description = "Minimum number of containers to run"
}
