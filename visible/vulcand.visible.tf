resource "aws_security_group" "elb_vulcand_visible" {
  name = "visible-vulcand-external-elb"
  description = "VISIBLE vulcand external public ELB."
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

  provisioner "local-exec" {
    command = <<COMMAND
aws iam upload-server-certificate \
  --path "/tls/" \
  --server-certificate-name "STAR.cloud.nlab.io" \
  --certificate-body file://$PWD/certificates/STAR_cloud_nlab_io.crt \
  --certificate-chain file://$PWD/certificates/STAR_cloud_nlab_io_chain.crt \
  --private-key file://$PWD/certificates/STAR_cloud_nlab_io.key
COMMAND
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

  security_groups = [ "${aws_security_group.elb_vulcand_visible.id}" ]

  provisioner "local-exec" {
    command = <<COMMAND
aws elb add-tags \
  --load-balancer-names \
    "${aws_elb.vulcand_visible.name}" \
  --tags \
    "Key=Team,Value=${var.aws_tag_value_team}" \
    "Key=CostCenter,Value=${var.aws_tag_value_cost_center}"
COMMAND
  }
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
