module "leaders-virttype" {
  source = "github.com/terraform-community-modules/tf_aws_virttype"
  instance_type = "${var.leaders-instance_type}"
}

module "leaders_ami" {
  source = "github.com/terraform-community-modules/tf_aws_coreos_ami"
  region = "${var.region}"
  channel = "${var.leaders-coreos_channel}"
  virttype = "${module.leaders-virttype.prefer_hvm}"
}

resource "aws_launch_configuration" "kubernetes-leaders" {
    image_id = "${module.leaders_ami.ami_id}"
    instance_type = "${var.leaders-instance_type}"
    security_groups = ["${var.sg}"]
    associate_public_ip_address = false
    user_data = "${file(format(\"%s/master.yaml\", path.module))}"
    key_name = "${var.admin_key_name}"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "kubernetes-leaders" {
  availability_zones = ["${var.primary-az}", "${var.secondary-az}"]
  name = "kubernetes-leaders"
  max_size = "${toint(var.master-cluster-size)+1}"
  min_size = "${var.master-cluster-size}"
  desired_capacity = "${var.master-cluster-size}"
  health_check_grace_period = 120
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.kubernetes-leaders.name}"
  vpc_zone_identifier = [ "${var.primary-az-subnet}", "${var.secondary-az-subnet}" ]
  tag {
    key = "Name"
    value = "kubernetes-leaders"
    propagate_at_launch = true
  }
}

