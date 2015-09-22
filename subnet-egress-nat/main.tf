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

resource "aws_autoscaling_group" "subnet_egress_nat" {
    name = "${terraform_remote_state.vpc.output.vpc_id}-subnet_egress_nat_asg-${element(split(",", var.availability_zones), count.index)}"
    count = "${length(split(",", var.availability_zones))}"

    availability_zones = [ "${element(split(",", var.availability_zones), count.index)}" ]
    vpc_zone_identifier = [ "${element(split(",", terraform_remote_state.vpc.output.public_subnets), count.index)}" ]
    launch_configuration = "${element(aws_launch_configuration.subnet_egress_nat.*.id, count.index)}"

    max_size = "2"
    min_size = "1"
    desired_capacity = "1"
    health_check_grace_period = "300"
    health_check_type = "EC2"
    default_cooldown = "300"

    tag {
        key = "Name"
        value = "subnet_egress_nat"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "subnet_egress_nat" {
    count = "${length(split(",", var.availability_zones))}"

    image_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    iam_instance_profile = "${element(aws_iam_instance_profile.subnet_egress_nat.*.name, count.index)}"
    key_name = "${var.ec2_key_name}"
    security_groups = [ "${split(",", terraform_remote_state.vpc.output.subnet_egress_nat_instances_sg_id)}" ]
    user_data = "${element(template_file.cloud_config.*.rendered, count.index)}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "template_file" "cloud_config" {
    filename = "cloud_config.yaml.tmpl"
    count = "${length(split(",", var.availability_zones))}"

    vars {
        aws_region = "${var.aws_region}"
        vpc_cidr_range = "${var.vpc_cidr_range}"
        # TODO: verify mappings are created between public & private subnets in the same AZ
        network_interface_id = "${element(split(",", terraform_remote_state.vpc.output.subnet_egress_nat_network_interfaces), count.index)}"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_instance_profile" "subnet_egress_nat" {
    count = "${length(split(",", var.availability_zones))}"

    name = "subnet_egress_nat_instance_profile-${element(split(",", var.availability_zones), count.index)}"
    path = "/${terraform_remote_state.vpc.output.vpc_id}/"
    roles = ["${element(aws_iam_role.subnet_egress_nat.*.name, count.index)}"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role" "subnet_egress_nat" {
    count = "${length(split(",", var.availability_zones))}"

    name = "subnet_egress_nat_role-${element(split(",", var.availability_zones), count.index)}"
    path = "/${terraform_remote_state.vpc.output.vpc_id}/"
    assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_policy" "subnet_egress_nat" {
    count = "${length(split(",", var.availability_zones))}"

    name = "subnet_egress_nat_policy-${element(split(",", var.availability_zones), count.index)}"
    path = "/${terraform_remote_state.vpc.output.vpc_id}/"
    description = "Allow subnet egress NAT instances to attach the network interface for their subnet"
    # Check out: http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-supported-iam-actions-resources.html
    # "Resource": "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:network-interface/${element(split(",", terraform_remote_state.vpc.output.subnet_egress_nat_network_interfaces), count.index)}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachNetworkInterface"
      ],
      "Resource": "*"
    }
  ]
}
EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_policy_attachment" "subnet_egress_nat" {
    count = "${length(split(",", var.availability_zones))}"

    name = "subnet_egress_nat_policy_attachment-${element(split(",", var.availability_zones), count.index)}"
    roles = ["${element(aws_iam_role.subnet_egress_nat.*.name, count.index)}"]
    policy_arn = "${element(aws_iam_policy.subnet_egress_nat.*.arn, count.index)}"

    lifecycle {
        create_before_destroy = true
    }
}
