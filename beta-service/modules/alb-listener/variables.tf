variable "service_name" {
  description = "Name of service"
}

variable "container_port" {
  description = "Port that service will listen on"
}

variable "vpc_id" {
  description = "Id of the VPC where service should be deployed"
}

variable "alb_listener_arn" {
  description = "ARN of ALB listener"
}
