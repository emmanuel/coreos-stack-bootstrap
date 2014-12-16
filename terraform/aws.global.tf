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

resource "aws_security_group" "public_ssh" {
  name = "SSH from anywhere (${var.environment})"
  description = "Allow SSH from anywhere."

  # public ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
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

}

