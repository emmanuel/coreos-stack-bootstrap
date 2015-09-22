provider "aws" {
    region = "${var.aws_region}"
}

resource "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "tf-remote-state"
        key = "innovation-platform/dev/vpc/terraform.tfstate"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "bastion" {
    name = "${terraform_remote_state.vpc.output.vpc_id}-bastion-asg"

    availability_zones = [ "${split(",", var.availability_zones)}" ]
    vpc_zone_identifier = [ "${split(",", terraform_remote_state.vpc.output.public_subnets)}" ]
    launch_configuration = "${aws_launch_configuration.bastion.id}"
    load_balancers = [ "${terraform_remote_state.vpc.output.bastion_elb_id}" ]

    max_size = "2"
    min_size = "1"
    desired_capacity = "1"
    health_check_grace_period = "300"
    health_check_type = "EC2"
    default_cooldown = "120"

    tag {
        key = "Name"
        value = "bastion"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "bastion" {
    # name = "${terraform_remote_state.vpc.output.vpc_id}-bastion-launch_config"
    image_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    # iam_instance_profile = "${var.iam_instance_profile}"
    key_name = "${var.ec2_key_name}"
    security_groups = [ "${terraform_remote_state.vpc.output.bastion_instances_sg_id}" ]
    user_data = "${template_file.cloud_config.rendered}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "template_file" "cloud_config" {
    filename = "cloud_config.yaml.tmpl"

    lifecycle {
        create_before_destroy = true
    }
}
