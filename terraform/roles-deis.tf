resource "aws_autoscaling_group" "deis" {
  name = "deis (${var.environment} / ${var.aws_instance_type_deis})"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 12
  min_size = 0
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 0
  force_delete = true
  launch_configuration = "${aws_launch_configuration.deis.name}"
  load_balancers = [ "${aws_elb.deis_controller.name}" ]
}

resource "aws_launch_configuration" "deis" {
  name = "deis (${var.environment} / ${var.aws_instance_type_deis})"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type_deis}"
  security_groups = [ "${aws_security_group.cluster.id}",
                      "${aws_security_group.public_ssh.id}",
                      "${aws_security_group.deis_services.id}",
                      "${aws_security_group.deis-services-elb_ingress.id}",
                      "${aws_security_group.deis_services_control.id}" ]
  key_name = "${var.aws_ec2_keypair}"
  user_data = <<USER_DATA
#cloud-config

dynamic:
  fleet_metadata: &FLEET_METADATA
    metadata: instance_type=${var.aws_instance_type_deis},public_ip=$public_ipv4,region=${var.aws_region},role=deis
  etcd_servers: &ETCD_SERVERS
    etcd_servers: "http://${aws_elb.etcd.dns_name}:4001"
${file("cloud-config-deis.yaml")}
USER_DATA
}

# services accessible from outside the cluster via an ELB
resource "aws_security_group" "deis_services" {
  name = "Deis services (${var.environment})"
  description = "Allow ingress for Deis services (${var.environment})."

  # deis controller api (TCP)
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

# services accessible from outside the cluster via an ELB
resource "aws_security_group" "deis-services-elb_ingress" {
  # vpc_id = "${aws_vpc.a_vpc_name.id}"
  name = "Deis services accessible via ELB (${var.environment})"
  description = "Allow ingress from ELBs for deis services accessible externally (${var.environment})."

  # deis controller api (TCP)
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_deis.id}" ]
  }

  # deis controller api (HTTPS)
  ingress {
    from_port = 2222
    to_port =  2222
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_deis.id}" ]
  }
}

# services accessible cluster-wide, but (generally) internal-only
resource "aws_security_group" "deis_services_control" {
  name = "Deis private (${var.environment})"
  description = "Deis services private communication rules."

  # logger
  # 514/udp
  ingress {
    from_port = 514
    to_port =  514
    protocol = "udp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # registry
  # 5000
  ingress {
    from_port = 5000
    to_port =  5000
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # postgres
  # 5432
  ingress {
    from_port = 5432
    to_port =  5432
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # redis
  # 6379
  ingress {
    from_port = 6379
    to_port =  6379
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # store monitor
  # 6789
  ingress {
    from_port = 6789
    to_port =  6789
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # controller
  # 8000
  ingress {
    from_port = 8000
    to_port =  8000
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # store gateway
  # 8888
  ingress {
    from_port = 8888
    to_port =  8888
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }
}

resource "aws_security_group" "elb_deis" {
  name = "Deis ELB (${var.environment})"
  description = "Deis ELB (${var.environment})."

  # deis controller api
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }

  # deis builder api
  ingress {
    from_port = 2222
    to_port =  2222
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

resource "aws_elb" "deis_controller" {
  name = "deis-controller-public-${var.environment}"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 80
    instance_protocol = "http"
  }

  listener {
    lb_port = 2222
    lb_protocol = "tcp"
    instance_port = 2222
    instance_protocol = "tcp"
  }

  health_check {
    target = "HTTP:80/health-check"
    healthy_threshold = 4
    unhealthy_threshold = 2
    timeout = 5
    interval = 15
  }

  security_groups = [ "${aws_security_group.elb_deis.id}" ]
}

resource "aws_route53_record" "deis_controller" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "deis-controller.${var.environment}.cloud.nlab.io"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.deis_controller.dns_name}" ]
}
