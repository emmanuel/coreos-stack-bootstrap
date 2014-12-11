resource "aws_autoscaling_group" "control" {
  name = "control (${var.environment} / ${var.aws_instance_type_control})"
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  max_size = 12
  min_size = 3
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  launch_configuration = "${aws_launch_configuration.control.name}"
}

resource "aws_launch_configuration" "control" {
  name = "control (${var.environment} / ${var.aws_instance_type_control})"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type_control}"
  security_groups = [ "${aws_security_group.cluster.id}",
                      "${aws_security_group.public_ssh.id}",
                      "${aws_security_group.cluster_services.id}",
                      "${aws_security_group.cluster_services-elb_ingress.id}",
                      "${aws_security_group.cluster_services_control.id}" ]
  key_name = "${var.aws_ec2_keypair}"
  user_data = <<USER_DATA
#cloud-config

dynamic:
  fleet_metadata: &FLEET_METADATA
    metadata: instance_type=${var.aws_instance_type_control},public_ip=$public_ipv4,region=${var.aws_region},role=control
  discovery_url: &ETCD_DISCOVERY_URL
    discovery: ${var.etcd_discovery_url}
${file("cloud-config-control.yaml")}
USER_DATA
}

# services accessible cluster-wide, but (generally) internal-only
resource "aws_security_group" "cluster_services" {
  name = "Cluster services (${var.environment})"
  description = "Allow all cluster instances to access these cluster-services ports."

  # etcd client (http)
  ingress {
    from_port = 4001
    to_port =  4001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # influxdb api
  ingress {
    from_port = 8086
    to_port =  8086
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # zookeeper client
  ingress {
    from_port = 2181
    to_port =  2181
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # kafka client
  ingress {
    from_port = 9092
    to_port =  9092
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  # elasticsearch client
  ingress {
    from_port = 9200
    to_port =  9200
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

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
resource "aws_security_group" "cluster_services-elb_ingress" {
  # vpc_id = "${aws_vpc.a_vpc_name.id}"
  name = "Cluster services accessible via ELB (${var.environment})"
  description = "Allow ELB instances to access these cluster service ports."

  # etcd api
  ingress {
    from_port = 4001
    to_port =  4001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_etcd.id}" ]
  }

  # InfluxDB api
  ingress {
    from_port = 8086
    to_port =  8086
    protocol = "tcp"
    security_groups = [ "${aws_security_group.elb_influxdb.id}" ]
  }
}

# services accessible cluster-wide, but (generally) internal-only
resource "aws_security_group" "cluster_services_control" {
  name = "Cluster-services private (${var.environment})"
  description = "Allow all cluster_services instances to access these private cluster service ports."

  # etcd raft
  ingress {
    from_port = 7001
    to_port =  7001
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_services.id}" ]
  }

  # influxdb web
  ingress {
    from_port = 8083
    to_port =  8083
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_services.id}" ]
  }

  # influxdb consensus
  ingress {
    from_port = 8090
    to_port =  8090
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_services.id}" ]
  }

  # influxdb replication
  ingress {
    from_port = 8099
    to_port =  8099
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_services.id}" ]
  }

  # zookeeper peer
  ingress {
    from_port = 2888
    to_port =  2888
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_services.id}" ]
  }
  
  # zookeeper leader election
  ingress {
    from_port = 3888
    to_port =  3888
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_services.id}" ]
  }

  # elasticsearch peer
  ingress {
    from_port = 9300
    to_port =  9300
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster_services.id}" ]
  }
}

resource "aws_security_group" "elb_etcd" {
  name = "Etcd internal ELB (${var.environment})"
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

resource "aws_security_group" "elb_influxdb" {
  name = "InfluxDB ELB (${var.environment})"
  description = "Allow public to access this InfluxDB port."

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

  security_groups = [ "${aws_security_group.elb_influxdb.id}" ]
}

resource "aws_route53_record" "influxdb" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "influxdb.${var.environment}.cloud.nlab.io"
  type = "CNAME"
  ttl = "60"
  records = [ "${aws_elb.influxdb.dns_name}" ]
}

resource "aws_s3_bucket" "grafana" {
  bucket = "grafana-${var.environment}-nlab-cloud"
  # TODO: tighten up the Grafana access control
  acl = "public-read"

  # provisioner "local-exec" {
  #   command = "aws s3 cp ../grafana/dist/grafana-1.9.0-rc1 s3://grafana-${var.environment}-nlab-cloud --recursive --acl public-read > /dev/null"
  #   command = "aws s3 cp ../grafana/conf/config.js s3://grafana-${var.environment}-nlab-cloud --acl public-read"
  #   command = "aws s3 website s3://grafana-${var.environment}-nlab-cloud --index-document index.html"
  # }
}

# Something like this should work once Route53 Alias records are supported by Terraform.
#   In the meantime, CNAMEs don't work either, because S3 inspects the HTTP Host header.
# resource "aws_route53_record" "grafana" {
#   zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
#   name = "grafana.${var.environment}.cloud.nlab.io"
#   type = "A"
#   ttl = "60"
#   records = [ "ALIAS grafana-${var.environment}-nlab-cloud.s3-us-west-2.amazonaws.com" ]
# }
