provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

module "vpc" {
    source = "github.com/terraform-community-modules/tf_aws_vpc"

    name = "test-vpc"

    cidr = "172.33.0.0/16"
    private_subnets = "172.33.1.0/24,172.33.2.0/24,172.33.3.0/24"
    public_subnets = "172.33.101.0/24,172.33.102.0/24,172.33.103.0/24"

    azs = "us-west-2a,us-west-2b,us-west-2c"
}

module "subnet-egress-nat-asg" {
    source = "tf_aws_subnet_asg"


    launch_config_name = "${var.stack_name}-subnet-egress-nat-test-launch_config"
    ami_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
    key_name = "${var.ec2_key_name}"
    security_group_ids = "${aws_security_group.cluster_members.id}"
    user_data = "${template_file.test-cloud_config.rendered}"

    asg_name = "${var.stack_name}-subnet-egress-nat-test-asg"
    asg_max_size = 2
    asg_min_size = 1
    asg_desired_capacity = 1
    asg_health_check_type = "EC2"
    health_check_grace_period = "${var.health_check_grace_period}"
    default_cooldown = "${var.default_cooldown}"

    availability_zones = "${var.availability_zones}"
    subnet_ids = "${module.vpc.private_subnets}"
}

resource "template_file" "subnet-egress-nat-test-cloud_config" {
    filename = "subnet-egress-nat-test-cloud_config.yaml.tmpl"

    vars {
        # etcd_discovery_url = "${var.etcd_discovery_url}"
    }
}

resource "aws_security_group" "cluster_members" {
    name = "cluster_members_allow_all"
    description = "Allow all traffic between cluster members"
    vpc_id = "${module.vpc.vpc_id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = true
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        self = true
    }

    tags {
        Name = "allow_all_intra_cluster_traffic_sg"
        StackName = "${var.stack_name}"
    }
}

resource "aws_iam_instance_profile" "test_profile" {
    name = "test_profile"
    path = "/${var.stack_name}/"
    roles = ["${aws_iam_role.test_role.name}"]
}

resource "aws_iam_role" "test_role" {
    name = "test_role"
    path = "/${var.stack_name}/"
    assume_role_policy = <<ROLE_POLICY
{
    "Version": "2012-10-17",
        "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
ROLE_POLICY
}
