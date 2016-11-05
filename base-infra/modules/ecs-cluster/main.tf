# The ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.cluster_name}"
}

# The Datadog agent task definition
data "template_file" "datadog_agent_task_definition" {
  template = "${file("${path.module}/datadog-agent-task-definition.json")}"

  vars {
    datadog_api_key = "${var.datadog_api_key}"
  }
}

# The hello world task definition
data "template_file" "hello_world_task_definition" {
  template = "${file("${path.module}/hello-world-task-definition.json")}"
}

# The ECS task that specifies which Docker container we need to run the Datadog agent container
resource "aws_ecs_task_definition" "datadog_agent" {
  family = "dd-agent-task"
  volume {
    name = "docker_sock"
    host_path = "/var/run/docker.sock"
  }
  volume {
    name = "proc"
    host_path = "/proc/"
  }
  volume {
    name = "cgroup"
    host_path = "/cgroup/"
  }
  container_definitions = "${data.template_file.datadog_agent_task_definition.rendered}"
}

# The ECS task that specifies which Docker container we need to run the hello world container
resource "aws_ecs_task_definition" "hello_world" {
  family = "hello-world"
  volume {
    name = "www"
    host_path = "/var/www/html"
  }
  container_definitions = "${data.template_file.hello_world_task_definition.rendered}"
}
