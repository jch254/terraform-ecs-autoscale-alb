output "alb_listener_arn" {
  value = "${aws_alb_listener.instance_listener.arn}"
}

output "target_group_arn" {
  value = "${aws_alb_target_group.instance_tg.arn}"
}
