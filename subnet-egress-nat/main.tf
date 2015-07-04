provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

resource "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "tf-remote-state"
        key = "innovation-platform-dev/vpc/terraform.tfstate"
    }
}

module "subnet-egress-nat-asg" {
    source = "../tf_aws_subnet_asg"

    launch_config_name = "${var.stack_name}-subnet-egress-nat-launch_config"
    ami_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    iam_instance_profile = ""
    key_name = "${var.ec2_key_name}"
    security_group_ids = "${terraform_remote_state.vpc.output.subnet_egress_nat_instances_sg_id}"
    user_data = "${template_file.subnet-egress-nat-test-cloud_config.rendered}"

    asg_name = "${var.stack_name}-subnet-egress-nat-asg"
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
    filename = "cloud_config.yaml.tmpl"

    vars {
        network_prefix = "172.33"
    }
}
