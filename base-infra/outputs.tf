output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "alb_listener_arn" {
  value = "${module.alb.alb_listener_arn}"
}

output "cluster_name" {
  value = "${module.ecs_cluster.cluster_name}"
}

output "ecs_service_role_arn" {
  value = "${module.security.ecs_service_role_arn}"
}

output "ecs_service_autoscale_role_arn" {
  value = "${module.security.ecs_service_autoscale_role_arn}"
}
