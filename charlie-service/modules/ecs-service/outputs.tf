output "service_name" {
  value = "${aws_ecs_service.charlie_service.name}"
}
