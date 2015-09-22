output "launch_config_id" {
  value = "${aws_launch_configuration.bastion.id}"
}

output "autoscaling_group_id" {
  value = "${aws_autoscaling_group.bastion.id}"
}
