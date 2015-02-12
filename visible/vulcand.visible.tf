resource "aws_security_group" "elb_vulcand_visible" {
  name = "visible-vulcand-external-elb"
  description = "VISIBLE vulcand external public ELB."

  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_elb" "vulcand_visible" {
  name = "visible-vulcand-external"
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

  security_groups = [ "${aws_security_group.elb_vulcand_visible.id}" ]
}

resource "aws_route53_record" "vulcand_visible_api" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "api.cloud.nlab.io"
  type = "ALIAS"
  ttl = "900"
  records = [ "${aws_elb.vulcand_visible.dns_name}" ]
}

resource "aws_route53_record" "vulcand_visible_docker-registry" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "docker.cloud.nlab.io"
  type = "ALIAS"
  ttl = "900"
  records = [ "${aws_elb.vulcand_visible.dns_name}" ]
}

resource "aws_route53_record" "vulcand_visible_influxdb" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "influxdb.cloud.nlab.io"
  type = "ALIAS"
  ttl = "900"
  records = [ "${aws_elb.vulcand_visible.dns_name}" ]
}
