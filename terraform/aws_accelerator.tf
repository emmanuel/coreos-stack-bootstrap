provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_security_group" "cluster" {
  name = "Cluster instances (${var.environment})"
  description = "All instances that communicate from within the cluster."

  ingress {
    from_port = 65535
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

  name = "Cluster-public (${var.environment})"
resource "aws_security_group" "public_ssh" {
  description = "Allow SSH from anywhere."

  # public ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

resource "aws_security_group" "elb-api" {
  name = "Sandbox API ELB (${var.environment})"
  description = "Sandbox API ELB (${var.environment})"

  # nsandbox-fake-api-store
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

resource "aws_elb" "api" {
  name = "api-${var.environment}"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]

  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = 19110
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:19110/stores/1"
    interval = 30
  }

  security_groups = [ "${aws_security_group.elb-api.id}" ]
}

resource "aws_route53_record" "api" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "api.${var.environment}.cloud.nlab.io"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.api.dns_name}" ]
}
