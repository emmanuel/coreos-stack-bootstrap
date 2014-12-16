resource "aws_autoscaling_group" "service" {
  name = "service (${var.environment} / ${var.aws_instance_type_service})"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 12
  min_size = 3
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  launch_configuration = "${aws_launch_configuration.service.name}"
}

resource "aws_launch_configuration" "service" {
  name = "service (${var.environment} / ${var.aws_instance_type_service})"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type_service}"
  security_groups = [ "${aws_security_group.cluster.id}",
                      "${aws_security_group.public_ssh.id}",
                      "${aws_security_group.services.id}",
                      "${aws_security_group.services-elb_ingress.id}" ]
  key_name = "${var.aws_ec2_keypair}"
  user_data = <<USER_DATA
#cloud-config

dynamic:
  fleet_metadata: &FLEET_METADATA
    metadata: instance_type=${var.aws_instance_type_service},public_ip=$public_ipv4,region=${var.aws_region},role=service
  discovery_url: &ETCD_DISCOVERY_URL
    discovery: ${var.etcd_discovery_url}
${file("cloud-config-service.yaml")}
USER_DATA
}
