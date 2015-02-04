resource "aws_security_group" "elb_gtin_visible" {
  name = "visible-gtin-external-elb"
  description = "VISIBLE GTIN service external public ELB."

  # GTIN service
  ingress {
    from_port = 80
    to_port =  80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "aws_elb" "gtin_visible" {
  name = "visible-gtin-external"
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
    target = "HTTP:19111/stores/health/gtins/check"
    interval = 5
  }

  security_groups = [ "${aws_security_group.elb_gtin_visible.id}" ]
}

resource "aws_route53_record" "gtin_visible" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "gtin.api.cloud.nlab.io"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.gtin_visible.dns_name}" ]
}
