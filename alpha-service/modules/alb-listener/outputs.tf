output "target_group_arn" {
  value = "${aws_alb_target_group.alpha_service_tg.arn}"
}
