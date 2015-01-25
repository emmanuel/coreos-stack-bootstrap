resource "aws_autoscaling_group" "control" {
  name = "autoscaling_group-control-${var.environment}"
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
  name = "launch_configuration-control-${var.environment}"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  security_groups = [ "${aws_security_group.cluster.id}",
                      "${aws_security_group.public_ssh.id}",
                      "${aws_security_group.cluster_services.id}",
                      "${aws_security_group.cluster_services-elb_ingress.id}" ]
  key_name = "${var.aws_ec2_keypair}"
  user_data = <<USER_DATA
#cloud-config

dynamic:
  fleet_metadata: &FLEET_METADATA
    metadata: environment=${var.environment},instance_type=${var.aws_instance_type},public_ip=$public_ipv4,region=${var.aws_region},role=control
  discovery_url: &ETCD_DISCOVERY_URL
    discovery: ${var.etcd_discovery_url}
  # TODO: stop distributing long-lived AWS keys once Terraform supports IAM instance profiles
  # on launch configurations: https://github.com/hashicorp/terraform/issues/28
  aws_environment: &STATIC_AWS_ENVIRONMENT
    content: |
      AWS_REGION=${var.aws_region}
      AWS_ACCESS_KEY=${var.instance_aws_access_key}
      AWS_SECRET_KEY=${var.instance_aws_secret_key}
      VULCAND_ELB_LOAD_BALANCER_NAME=${aws_elb.vulcand.name}
${file("cloud-config.yaml")}
USER_DATA
}

resource "aws_security_group" "cluster_services-elb_ingress" {
  # vpc_id = "${aws_vpc.a_vpc_name.id}"
  name = "cluster_services-elb_ingress-${var.environment}"
  description = "Allow ELBs to make these cluster service ports accessible from outside the cluster (${var.environment})"

  # etcd api
  ingress {
    from_port = 4001
    to_port =  4001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_etcd.id}" ]
  }

  # vulcand traffic (8181) and API (8182)
  ingress {
    from_port = 8181
    to_port =  8182
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_vulcand.id}" ]
  }

  # GTIN service traffic (19111)
  ingress {
    from_port = 19111
    to_port =  19111
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_gtin.id}" ]
  }
}

resource "aws_security_group" "elb_gtin" {
  name = "gtin-external-elb-${var.environment}"
  description = "GTIN service external ELB (${var.environment})."

  # GTIN service
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_elb" "gtin" {
  name = "gtin-external-${var.environment}"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 19111
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "HTTP:19111/stores/3/gtins/1"
    interval = 5
  }

  security_groups = [ "${aws_security_group.elb_gtin.id}" ]
}

resource "aws_security_group" "elb_etcd" {
  name = "etcd-internal-elb-${var.environment}"
  description = "Etcd internal ELB (${var.environment})."

  # etcd api
  ingress {
    from_port = 4001
    to_port =  4001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }
}

resource "aws_elb" "etcd" {
  name = "etcd-internal-${var.environment}"
  # internal = true
  # vpc_zone_identifier = "${var.vpc_zone_identifier}"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]

  listener {
    lb_port = 4001
    lb_protocol = "http"
    instance_port = 4001
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:4001/version"
    interval = 30
  }

  security_groups = [ "${aws_security_group.elb_etcd.id}" ]
}

resource "aws_security_group" "elb_vulcand" {
  name = "vulcand-public-${var.environment}"
  description = "Allow public access to Vulcand."

  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_elb" "vulcand" {
  name = "vulcand-public-${var.environment}"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 8181
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 2
    timeout = 2
    target = "HTTP:8182/v2/status"
    interval = 10
  }

  security_groups = [ "${aws_security_group.elb_vulcand.id}" ]
}

resource "aws_route53_record" "vulcand" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "api.${var.environment}.cloud.nlab.io"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.vulcand.dns_name}" ]
}
