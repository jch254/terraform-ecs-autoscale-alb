output "target_group_arn" {
  value = "${aws_alb_target_group.beta_service_tg.arn}"
}
