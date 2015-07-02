provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

resource "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "tf-remote-state"
        key = "innovation-platform-prod/vpc/terraform.tfstate"
    }
}

module "subnet-egress-nat-asg" {
    source = "../tf_aws_subnet_asg"

    launch_config_name = "${var.stack_name}-subnet-egress-nat-launch_config"
    # launch_config_name = "subnet-egress-nat-launch_config"
    ami_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    iam_instance_profile = ""
    key_name = "${var.ec2_key_name}"
    security_group_ids = "${aws_security_group.subnet-egress-nat-instances.id}"
    user_data = "${template_file.subnet-egress-nat-test-cloud_config.rendered}"
    # user_data = ""

    asg_name = "${var.stack_name}-subnet-egress-nat-asg"
    # asg_name = "subnet-egress-nat-asg"
    asg_max_size = 2
    asg_min_size = 1
    asg_desired_capacity = 1
    asg_health_check_type = "EC2"
    health_check_grace_period = "${var.health_check_grace_period}"
    default_cooldown = "${var.default_cooldown}"

    availability_zones = "${var.availability_zones}"
    subnet_ids = "${terraform_remote_state.vpc.output.public_subnets}"
}

resource "template_file" "subnet-egress-nat-test-cloud_config" {
    filename = "subnet-egress-nat-test-cloud_config.yaml.tmpl"

    vars {
        network_prefix = "172.33"
    }
}

resource "aws_security_group" "subnet-egress-nat-instances" {
    name = "${var.stack_name}-subnet-egress-nat-instances-allow-egress"
    description = "Allow egress traffic from DMZ instances"
    vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        security_groups = [ "${aws_security_group.cluster_members.id}" ]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    tags {
        Name = "allow_cluster_members_to_connect_to_subnet_egress_sg"
    }
}

resource "aws_security_group" "cluster_members" {
    name = "${var.stack_name}-cluster_members_allow_all"
    description = "Allow all traffic between cluster members"
    vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"

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
    }
}
