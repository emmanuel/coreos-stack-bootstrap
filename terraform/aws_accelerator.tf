
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_launch_configuration" "standard" {
  name = "launch-configuration-${var.environment}"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  security_groups = [ "${aws_security_group.public.id}",
                      "${aws_security_group.private.id}",
                      "${aws_security_group.elb-ingress.id}" ]
  key_name = "${var.aws_ec2_keypair}"
  user_data = "${file("cloud-config.yaml")}"
#   user_data = <<USER_DATA
# #cloud-config
#
# dynamic:
#   fleet_metadata: &FLEET_METADATA
#     metadata: public_ip=$public_ipv4,region=${var.aws_region},instance_type=${var.aws_instance_type}
#   discovery_url: &ETCD_DISCOVERY_URL
#     discovery: ${var.etcd_discovery_url}
# ${file("cloud-config.yaml")}
# USER_DATA
}

resource "aws_autoscaling_group" "standard" {
  name = "Cluster (${var.environment} / ${var.aws_instance_type})"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 12
  min_size = 3
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  launch_configuration = "${aws_launch_configuration.standard.name}"
}

resource "aws_security_group" "public" {
  name = "Cluster-public (${var.environment})"
  description = "Allow SSH from anywhere."

  # public ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

resource "aws_security_group" "private" {
  name = "Cluster-private (${var.environment})"
  description = "Cluster-private security group rules."

  # etcd http
  ingress {
    from_port = 4001
    to_port =  4001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.public.id}" ]
  }

  # etcd raft
  ingress {
    from_port = 7001
    to_port =  7001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.public.id}" ]
  }

  # influxdb web
  ingress {
    from_port = 8083
    to_port =  8083
    protocol = "tcp"
    security_groups = [ "${aws_security_group.public.id}" ]
  }

  # influxdb api
  ingress {
    from_port = 8086
    to_port =  8086
    protocol = "tcp"
    security_groups = [ "${aws_security_group.public.id}" ]
  }

  # influxdb consensus
  ingress {
    from_port = 8090
    to_port =  8090
    protocol = "tcp"
    security_groups = [ "${aws_security_group.public.id}" ]
  }

  # influxdb replication
  ingress {
    from_port = 8099
    to_port =  8099
    protocol = "tcp"
    security_groups = [ "${aws_security_group.public.id}" ]
  }
}

resource "aws_security_group" "elb-ingress" {
  # vpc_id = "${aws_vpc.a_vpc_name.id}"
  name = "Cluster ELB-accessible (${var.environment})"
  description = "Allow ingress from ELBs."

  # influxdb api
  ingress {
    from_port = 8086
    to_port =  8086
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb-influxdb.id}" ]
  }
}

resource "aws_security_group" "elb-influxdb" {
  name = "InfluxDB ELB (${var.environment})"
  description = "InfluxDB ELB (${var.environment})."

  # influxdb api
  ingress {
    from_port = 8086
    to_port =  8086
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

resource "aws_elb" "influxdb" {
  name = "influxdb-public-${var.environment}"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]

  listener {
    lb_port = 8086
    lb_protocol = "http"
    instance_port = 8086
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8086/ping"
    interval = 30
  }

  security_groups = [ "${aws_security_group.elb-influxdb.id}" ]
}

resource "aws_route53_record" "influxdb" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "${var.aws_route53_public_dns_name_influxdb}"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.influxdb.dns_name}" ]
}

# This should work just fine once A ALIAS record creation is supported by terraform
#resource "aws_route53_record" "influxdb" {
#   zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
#   name = "influxdb.cloud.nlab.io"
#   type = "A"
#   ttl = "300"
#   records = [ "ALIAS ${aws_elb.influxdb.dns_name}" ]
#   alias_target = 
#}
