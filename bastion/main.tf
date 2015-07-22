provider "aws" {
    region = "${var.aws_region}"
}

resource "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "tf-remote-state"
        key = "innovation-platform-dev/vpc/terraform.tfstate"
    }
}

resource "template_file" "cloud_config" {
    filename = "cloud_config.yaml.tmpl"
}

resource "aws_route53_record" "ssh" {
    zone_id = "${var.route53_zone_id}"
    name = "${var.stack_name}-ssh.cloud.nlab.io"
    type = "A"

    alias {
        name = "${aws_elb.main.dns_name}"
        zone_id = "${aws_elb.main.zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_elb" "main" {
    name = "${terraform_remote_state.vpc.output.vpc_id}-bastion-elb"
    availability_zones = [ "${split(",", var.availability_zones)}" ]

    listener {
        instance_port = 22
        instance_protocol = "tcp"
        lb_port = 2222
        lb_protocol = "tcp"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 5
        timeout = 3
        target = "TCP:22"
        interval = 30
    }

    idle_timeout = 300

    tags {
        Name = "bastion-elb"
    }
}

resource "aws_launch_configuration" "main" {
    name = "${terraform_remote_state.vpc.output.vpc_id}-bastion-launch_config"
    image_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    # iam_instance_profile = "${var.iam_instance_profile}"
    key_name = "${var.ec2_key_name}"
    security_groups = [ "${terraform_remote_state.vpc.output.bastion_instances_sg_id}" ]
    user_data = "${template_file.cloud_config.rendered}"
}

resource "aws_autoscaling_group" "main" {
    depends_on = [ "aws_launch_configuration.main" ]
    name = "${terraform_remote_state.vpc.output.vpc_id}-bastion-asg"

    availability_zones = [ "${split(",", var.availability_zones)}" ]
    vpc_zone_identifier = [ "${split(",", terraform_remote_state.vpc.output.public_subnets)}" ]
    launch_configuration = "${aws_launch_configuration.main.id}"
    load_balancers = [ "${aws_elb.main.id}" ]

    max_size = "2"
    min_size = "1"
    desired_capacity = "1"
    health_check_grace_period = "300"
    health_check_type = "EC2"
    default_cooldown = "120"
}
