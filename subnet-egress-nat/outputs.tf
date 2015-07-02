output "launch_config_id" {
  value = "${module.subnet-egress-nat-asg.launch_config_id}"
}

output "asg_ids" {
  value = "${module.subnet-egress-nat-asg.asg_ids}"
}
