resource "aws_autoscaling_group" "control" {
  name = "${var.environment}-autoscaling_group-control"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 12
  min_size = 5
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 5
  force_delete = true
  launch_configuration = "${aws_launch_configuration.control.name}"
  # load_balancers = [ "${aws_elb.etcd.name}" ]

  provisioner "local-exec" {
    command = <<COMMAND
      aws autoscaling create-or-update-tags --tags \
        "Key=Team,Value=${var.aws_tag_value_team},PropagateAtLaunch=true,ResourceId=${aws_autoscaling_group.control.name},ResourceType=auto-scaling-group" \
        "Key=CostCenter,Value=${var.aws_tag_value_cost_center},PropagateAtLaunch=true,ResourceId=${aws_autoscaling_group.control.name},ResourceType=auto-scaling-group"
COMMAND
  }

  provisioner "local-exec" {
    command = <<COMMAND
      aws autoscaling put-notification-configuration \
        --auto-scaling-group-name "${aws_autoscaling_group.control.name}" \
        --topic-arn "${var.aws_sns_topic_autoscaling_events_arn}" \
        --notification-types \
          autoscaling:EC2_INSTANCE_LAUNCH \
          autoscaling:EC2_INSTANCE_LAUNCH_ERROR \
          autoscaling:EC2_INSTANCE_TERMINATE \
          autoscaling:EC2_INSTANCE_TERMINATE_ERROR
COMMAND
  }
}

output "control_auto_scaling_group" {
  value = "${aws_autoscaling_group.control.id}"
}

resource "aws_launch_configuration" "control" {
  name = "${var.environment}-launch_configuration-control"
  image_id = "${lookup(var.coreos_amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "cluster_instance_profile"
  security_groups = [ "${aws_security_group.cluster.id}",
                      "${aws_security_group.public_ssh.id}",
                      "${aws_security_group.cluster_services.id}",
                      "${aws_security_group.cluster_services_elb_ingress.id}" ]
  key_name = "${var.aws_ec2_keypair}"
  user_data = <<USER_DATA
#cloud-config

dynamic:
  fleet_metadata: &FLEET_METADATA
    metadata: environment=${var.environment},instance_type=${var.aws_instance_type},public_ip=$public_ipv4,region=${var.aws_region},role=control
  discovery_url: &ETCD_DISCOVERY_URL
    discovery: ${var.etcd_discovery_url}
  aws_environment: &STATIC_AWS_ENVIRONMENT
    content: |
      AWS_REGION=${var.aws_region}
      AWS_EC2_INSTANCE_TYPE=${var.aws_instance_type}
      AWS_ACCESS_KEY=${var.instance_aws_access_key}
      AWS_SECRET_KEY=${var.instance_aws_secret_key}
  cluster_environment: &STATIC_CLUSTER_ENVIRONMENT
    content: |
      CLUSTER_ENVIRONMENT=${var.environment}
      CLUSTER_ROLE=control
${file("cloud-config.yaml")}
USER_DATA

  provisioner "local-exec" {
    command = <<COMMAND
aws ec2 create-tags \
  --resources \
    "${aws_security_group.cluster.id}" \
    "${aws_security_group.public_ssh.id}" \
    "${aws_security_group.cluster_services.id}" \
    "${aws_security_group.cluster_services_elb_ingress.id}" \
  --tags \
    "Key=Team,Value=${var.aws_tag_value_team}" \
    "Key=CostCenter,Value=${var.aws_tag_value_cost_center}"
COMMAND
  }
}

resource "aws_security_group" "cluster_services_elb_ingress" {
  # vpc_id = "${aws_vpc.a_vpc_name.id}"
  name = "${var.environment}-cluster_services_elb_ingress"
  description = "ENV(${var.environment}) Allow ELBs to make these cluster service ports accessible from outside the cluster."

  # vulcand traffic (8181) and API (8182)
  ingress {
    from_port = 8181
    to_port =  8182
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_vulcand.id}" ]
  }

  # (VISIBLE) vulcand traffic (8181) and API (8182)
  ingress {
    from_port = 8181
    to_port =  8182
    protocol = "tcp"
    security_groups = [ "${var.aws_security_group_elb_vulcand_visible_id}" ]
  }
}

resource "aws_security_group" "elb_vulcand" {
  name = "${var.environment}-vulcand-external"
  description = "ENV(${var.environment}) Allow external public access to Vulcand."

  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    from_port = 443
    to_port =  443
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_elb" "vulcand" {
  name = "${var.environment}-vulcand-external"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8181
    instance_protocol = "http"
  }

  listener {
    lb_port = 443
    lb_protocol = "https"
    instance_port = 8181
    instance_protocol = "http"
    ssl_certificate_id = "${var.aws_iam_server_certificate_arn}"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:8182/v2/status"
    interval = 10
  }

  security_groups = [ "${aws_security_group.elb_vulcand.id}" ]

  provisioner "local-exec" {
    command = <<COMMAND
aws elb add-tags \
  --load-balancer-names \
    "${aws_elb.vulcand.name}" \
  --tags \
    "Key=Team,Value=${var.aws_tag_value_team}" \
    "Key=CostCenter,Value=${var.aws_tag_value_cost_center}"
COMMAND
  }
}

resource "aws_route53_record" "private_api" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.environment}-api.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.vulcand.dns_name}" ]
}

resource "aws_route53_record" "private_influxdb" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.environment}-influxdb.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.vulcand.dns_name}" ]
}

resource "aws_route53_record" "private_docker_registry" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.environment}-docker.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.vulcand.dns_name}" ]
}
