resource "aws_security_group" "cluster" {
  name = "${var.environment}-cluster_instances"
  description = "ENV(${var.environment}) All instances that communicate from within the cluster."

  ingress {
    from_port = 65535
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [ "255.255.255.255/32" ]
  }
}

output "cluster_aws_security_group" {
  value = "${aws_security_group.cluster.id}"
}

resource "aws_security_group" "public_ssh" {
  name = "${var.environment}-ssh_from_anywhere"
  description = "ENV(${var.environment}) Allow SSH from anywhere."

  # public ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.allow_ssh_from}" ]
  }
}

output "public_ssh_aws_security_group" {
  value = "${aws_security_group.public_ssh.id}"
}

# services accessible cluster-wide
resource "aws_security_group" "cluster_services" {
  name = "${var.environment}-cluster_services"
  description = "ENV(${var.environment}) Allow all cluster instances to access all ports."

  ingress {
    from_port = 0
    to_port =  65535
    protocol = "tcp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }

  ingress {
    from_port = 0
    to_port =  65535
    protocol = "udp"
    security_groups = [ "${aws_security_group.cluster.id}" ]
  }
}

output "cluster_services_aws_security_group" {
  value = "${aws_security_group.cluster_services.id}"
}
