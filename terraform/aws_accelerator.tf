
provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_launch_configuration" "standard" {
  name = "launch-configuration"
  image_id = "${lookup(var.amis, var.aws_region)}"
  instance_type = "${var.aws_instance_type}"
  security_groups = [ "${aws_security_group.public.id}", "${aws_security_group.private.id}" ]
  user_data = "${file("cloud-config.yaml")}"
  key_name = "${var.aws_ec2_keypair}"
}

resource "aws_autoscaling_group" "standard" {
  availability_zones = [ "us-west-2a", "us-west-2b", "us-west-2c" ]
  name = "AWS Auto-scaling Group ${var.environment}"
  max_size = 12
  min_size = 3
  health_check_grace_period = 300
  health_check_type = "ELB"
  desired_capacity = 3
  force_delete = true
  launch_configuration = "${aws_launch_configuration.standard.name}"
}

resource "aws_security_group" "public" {
  # vpc_id = "${aws_vpc.a_vpc_name.id}"
  name = "Public security group (${var.environment})"
  description = "Public security group allowing ssh from anywhere."

  # public ssh
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${var.AllowSSHFrom}" ]
  }
}

resource "aws_security_group" "private" {

  name = "Private security group (${var.environment})"
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

resource "aws_security_group" "influxdb-elb" {

  name = "Public influxdb ELB security group (${var.environment})"
  description = "Cluster-private security group rules."

  # influxdb api
  ingress {
    from_port = 8086 
    to_port =  8086
    protocol = "tcp"
    cidr_blocks = [ "${var.AllowSSHFrom}" ]
  }

}

resource "aws_elb" "influxdb" {
  name = "influxdb-public"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  listener {
    instance_port = 8086
    instance_protocol = "http"
    lb_port = 8086
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 10
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:8086/ping"
    interval = 30
  }

  security_groups = [ "${aws_security_group.influxdb-elb.id}" ]
}