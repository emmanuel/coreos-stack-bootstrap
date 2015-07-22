output "launch_config_ids" {
  value = "${join(",", aws_launch_configuration.main.*.id)}"
  # value = "${aws_launch_configuration.main-a.id},${aws_launch_configuration.main-b.id},${aws_launch_configuration.main-c.id}"
}

output "autoscaling_group_ids" {
  value = "${join(",", aws_autoscaling_group.main.*.id)}"
  # value = "${aws_autoscaling_group.main-a.id},${aws_autoscaling_group.main-b.id},${aws_autoscaling_group.main-c.id}"
}

# output "cloud_config-a" {
#   value = "${template_file.cloud_config-a.rendered}"
# }
#
# output "cloud_config-b" {
#   value = "${template_file.cloud_config-b.rendered}"
# }
#
# output "cloud_config-c" {
#   value = "${template_file.cloud_config-c.rendered}"
# }
