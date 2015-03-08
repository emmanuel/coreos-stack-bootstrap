resource "aws_autoscaling_group" "control" {
  name = "${var.stack_name}-control-autoscale"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 9
  min_size = 3
  desired_capacity = 5
  # force_delete = true
  launch_configuration = "${aws_launch_configuration.control.name}"
  health_check_type = "ELB"
  health_check_grace_period = 300
  load_balancers = [ "${aws_elb.control.name}" ]

  provisioner "local-exec" {
    command = <<COMMAND
aws autoscaling create-or-update-tags \
  --tags \
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

resource "aws_launch_configuration" "control" {
  name = "${var.stack_name}-control-launch_config"
  image_id = "${var.coreos_ami}"
  instance_type = "${var.aws_instance_type}"
  iam_instance_profile = "cluster_instance_profile"
  security_groups = [ "${aws_security_group.cluster_instances.id}",
                      "${aws_security_group.cluster_services.id}",
                      "${aws_security_group.cluster_services_elb_ingress.id}" ]
  key_name = "${var.aws_ec2_key_name}"
  user_data = <<USER_DATA
#cloud-config

dynamic:
  fleet_metadata: &FLEET_METADATA
    metadata: instance_type=${var.aws_instance_type},public_ip=$public_ipv4,role=control
  etcd_discovery: &ETCD_DISCOVERY
    discovery: ${var.etcd_discovery_url}
  aws_environment_content: &AWS_ENVIRONMENT_CONTENT
    content: |
      AWS_ACCESS_KEY=${var.instance_aws_access_key}
      AWS_SECRET_KEY=${var.instance_aws_secret_key}
      AWS_REGION=${var.aws_region}
      AWS_EC2_INSTANCE_TYPE=${var.aws_instance_type}
      AWS_IAM_INSTANCE_PROFILE=cluster_instance_profile
  cluster_environment_content: &CLUSTER_ENVIRONMENT_CONTENT
    content: |
      CLUSTER_ENVIRONMENT=${var.stack_name}
      CLUSTER_ROLE=control
      CLUSTER_DNS_SUFFIX=cluster.local
${file("control-cloud_config.yaml")}
USER_DATA
}

resource "aws_security_group" "cluster_instances" {
  name = "${var.stack_name}-cluster_instances"
  description = "ENV(${var.stack_name}) All instances that communicate from within the cluster."

  tags {
    Team = "${var.aws_tag_value_team}"
    CostCenter = "${var.aws_tag_value_cost_center}"
  }

  ingress {
    from_port = 65535
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [ "255.255.255.255/32" ]
  }
}

resource "aws_security_group" "cluster_services" {
  name = "${var.stack_name}-cluster_services"
  description = "ENV(${var.stack_name}) Allow all cluster instances to access all ports."

  ingress {
    from_port = 0
    to_port =  65535
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_instances.id}" ]
  }

  tags {
    Team = "${var.aws_tag_value_team}"
    CostCenter = "${var.aws_tag_value_cost_center}"
  }

  ingress {
    from_port = 0
    to_port =  65535
    protocol = "udp"
    security_groups = [ "${aws_security_group.cluster_instances.id}" ]
  }
}

resource "aws_security_group" "cluster_services_elb_ingress" {
  name = "${var.stack_name}-cluster_services_elb_ingress"
  description = "ENV(${var.stack_name}) Allow ELBs to make these cluster service ports accessible from outside the cluster."
  vpc_id = "${var.aws_vpc_zone_identifier}"
  tags {
    Team = "${var.aws_tag_value_team}"
    CostCenter = "${var.aws_tag_value_cost_center}"
  }

  # ssh traffic
  ingress {
    from_port = 22
    to_port =  22
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_control.id}" ]
  }

  # etcd traffic (for health check)
  ingress {
    from_port = 4001
    to_port =  4001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_control.id}" ]
  }

  # vulcand traffic (8181) and API (8182)
  ingress {
    from_port = 8181
    to_port =  8182
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_control.id}" ]
  }

  # (VISIBLE) vulcand traffic (8181) and API (8182)
  ingress {
    from_port = 8181
    to_port =  8182
    protocol = "tcp"
    security_groups = [ "${var.aws_security_group_elb_vulcand_visible_id}" ]
  }
}

resource "aws_elb" "control" {
  name               = "${var.stack_name}-control-external"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  security_groups    = [ "${aws_security_group.elb_control.id}" ]

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

  listener {
    lb_port            = 2222
    instance_port      = 22
    lb_protocol        = "tcp"
    instance_protocol  = "tcp"
  }

  health_check {
    target              = "HTTP:4001/version"
    healthy_threshold   = 4
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 30
  }

  provisioner "local-exec" {
    command = <<COMMAND
aws elb add-tags \
  --load-balancer-names \
    "${aws_elb.control.name}" \
  --tags \
    "Key=Team,Value=${var.aws_tag_value_team}" \
    "Key=CostCenter,Value=${var.aws_tag_value_cost_center}"
COMMAND
  }
}

resource "aws_security_group" "elb_control" {
  name = "${var.stack_name}-control-external"
  description = "ENV(${var.stack_name}) Allow external access to services."

  tags {
    Team = "${var.aws_tag_value_team}"
    CostCenter = "${var.aws_tag_value_cost_center}"
  }

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

  ingress {
    from_port = 2222
    to_port =  2222
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

resource "aws_route53_record" "private_stack" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.stack_name}.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.control.dns_name}" ]
}

resource "aws_route53_record" "private_api" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.stack_name}-api.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.control.dns_name}" ]
}

resource "aws_route53_record" "private_consul" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.stack_name}-consul.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.control.dns_name}" ]
}

resource "aws_route53_record" "private_influxdb" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.stack_name}-influxdb.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.control.dns_name}" ]
}

resource "aws_route53_record" "private_docker_registry" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.stack_name}-docker.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.control.dns_name}" ]
}

resource "aws_route53_record" "private_elasticsearch" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.stack_name}-elasticsearch.cloud.nlab.io"
  type = "CNAME"
  ttl = "300"
  records = [ "${aws_elb.control.dns_name}" ]
}
