//
// Module: tf_aws_asg_elb
//

// Output the ID of the Launch Config
output "launch_config_id" {
    value = "${aws_launch_configuration.main.id}"
}

// Output the ID of the Launch Config
output "asg_ids" {
    value = "${join(\",\", aws_autoscaling_group.main.*.id)}"
}