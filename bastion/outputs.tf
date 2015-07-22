output "elb_dns" {
  value = "${aws_elb.main.dns_name}"
}

output "elb_id" {
  value = "${aws_elb.main.id}"
}

output "launch_config_id" {
  value = "${aws_launch_configuration.main.id}"
}

output "asg_id" {
  value = "${aws_autoscaling_group.main.id}"
}
