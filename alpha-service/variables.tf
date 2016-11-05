variable "region" {
  description = "AWS region to deploy to (e.g. ap-southeast-2)"
}

variable "service_name" {
  description = "Name of service"
}

variable "container_port" {
  description = "Port that service will listen on"
}

variable "docker_image" {
  description = "Docker image to run"
}

variable "docker_tag" {
  description = "Tag of docker image to run"
}

variable "container_cpu" {
  description = "The number of cpu units to reserve for the container. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  default = "256"
}

variable "container_memory" {
  description = "The number of MiB of memory to reserve for the container. See https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html"
  default = "256"
}

variable "min_capacity" {
  description = "Minimum number of containers to run"
  default = 2
}

variable "max_capacity" {
  description = "Minimum number of containers to run"
  default = 6
}
