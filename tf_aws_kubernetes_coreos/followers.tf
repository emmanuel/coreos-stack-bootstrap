resource "template_file" "follower-cloud_config" {
    filename = "follower.yaml.tmpl"

    vars {
        hello = "goodnight"
        world = "moon"
    }
}

module "follower-virttype" {
  source = "github.com/terraform-community-modules/tf_aws_virttype"
  instance_type = "${var.follower-instance_type}"
}

module "follower-ami" {
  source = "github.com/terraform-community-modules/tf_aws_coreos_ami"
  region = "${var.region}"
  channel = "${var.coreos-channel}"
  virttype = "${module.follower-virttype.prefer_hvm}"
}

module "follower-asg_elb" {
    source = "git.nordstrom.net/lab/ip-bootstrap/tf_aws_asg_elb"
    launch_config_name = "${var.followers-launch_config_name}"
    ami_id = "${var.follower-ami_id}"
    instance_type = "${var.followers-instance_type}"
    iam_instance_profile = "${var.follower-iam_instance_profile}"
    key_name = "${var.follower-key_name}"

    variable "security_groups" {}

    user_data = "${file(format(\"%s/follower.yaml\", path.module))}"

    // Auto-Scaling Group
    asg_name = "kubernetes-followers-test"
    asg_max_size = 3
    asg_min_size = 1
    asg_desired_capacity = 2

    health_check_grace_period = 300
    default_cooldown = 300
    health_check_type = "ELB"
    load_balancer_name = "${aws_elb.followers}"

    // Our template assumes a comma-separated list of AZs and VPC subnet IDs for them
    availability_zones = "us-west-2a,us-west-2b,us-west-2c"

    variable "subnet_ids" {
        description = "VPC subnet IDs for AZs"
    }

    aws_access_key = ""
    aws_secret_key = ""
    aws_region = ""
}

resource "aws_launch_configuration" "kubernetes-follower" {
  image_id = "${module.follower-ami.ami_id}"
  instance_type = "${var.follower-instance_type}"
  security_groups = ["${var.sg}"]
  associate_public_ip_address = false
  user_data = "${file(format(\"%s/leader.yaml\", path.module))}"
  key_name = "${var.admin_key_name}"
}

resource "aws_autoscaling_group" "kubernetes-follower" {
  availability_zones = ["${var.primary-az}", "${var.secondary-az}"]
  name = "kubernetes-follower"
  max_size = "${toint(var.node-cluster-size)+1}"
  min_size = "${var.node-cluster-size}"
  desired_capacity = "${var.node-cluster-size}"
  health_check_grace_period = 120
  health_check_type = "EC2"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.kubernetes-follower.name}"
  vpc_zone_identifier = [ "${var.primary-az-subnet}", "${var.secondary-az-subnet}" ]
  tag {
    key = "Name"
    value = "kubernetes-follower"
    propagate_at_launch = true
  }
}

