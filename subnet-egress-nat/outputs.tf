output "launch_config_ids" {
  value = "${join(",", aws_launch_configuration.subnet_egress_nat.*.id)}"
}

output "autoscaling_group_ids" {
  value = "${join(",", aws_autoscaling_group.subnet_egress_nat.*.id)}"
}
