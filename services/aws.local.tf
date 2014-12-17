resource "aws_autoscaling_group" "service" {
  name = "service (${var.environment} / ${var.aws_instance_type})"
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
  name = "service (${var.environment} / ${var.aws_instance_type})"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  security_groups = [ "${aws_security_group.cluster.id}",
                      "${aws_security_group.public_ssh.id}",
                      "${aws_security_group.cluster_services.id}",
                      "${aws_security_group.services.id}",
                      "${aws_security_group.services-elb_ingress.id}" ]
  key_name = "${var.aws_ec2_keypair}"
  user_data = <<USER_DATA
#cloud-config

dynamic:
  fleet_metadata: &FLEET_METADATA
    metadata: instance_type=${var.aws_instance_type},public_ip=$public_ipv4,region=${var.aws_region},role=service
  discovery_url: &ETCD_DISCOVERY_URL
    discovery: ${var.etcd_discovery_url}
  aws_environment: &STATIC_AWS_ENVIRONMENT
    content: |
      VULCAND_ELB_LOAD_BALANCER_NAME=${aws_elb.vulcand.name}
${file("cloud-config.yaml")}
USER_DATA
}

resource "aws_security_group" "services" {
  name = "Cluster services (${var.environment})"
  description = "Allow all cluster instances to access these cluster-services ports."

  # vulcan listening
  ingress {
    from_port = 8181
    to_port =  8181
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # vulcan api
  ingress {
    from_port = 8182
    to_port =  8182
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

}

# services accessible from outside the cluster via an ELB
resource "aws_security_group" "services-elb_ingress" {
  # vpc_id = "${aws_vpc.a_vpc_name.id}"
  name = "Cluster services accessible via ELB (${var.environment})"
  description = "Allow ELB instances to access these cluster service ports."

  # Vulcan api (health check on 8182, service traffic on 8181)
  ingress {
    from_port = 8181
    to_port =  8182
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_vulcand.id}" ]
  }

}

resource "aws_security_group" "elb_vulcand" {
  name = "Vulcan ELB (${var.environment})"
  description = "Allow public to access this vulcan port."

  # vulcan api
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
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
    target = "HTTP:8182/v1/status"
    interval = 10
  }

  security_groups = [ "${aws_security_group.elb_vulcand.id}" ]
}

resource "aws_route53_record" "api" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "api.${var.environment}.cloud.nlab.io"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.vulcand.dns_name}" ]
}

