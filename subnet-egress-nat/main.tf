provider "aws" {
    region = "${var.aws_region}"
}

resource "terraform_remote_state" "vpc" {
    backend = "s3"
    config {
        bucket = "tf-remote-state"
        key = "innovation-platform-dev/vpc/terraform.tfstate"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "template_file" "cloud_config" {
    filename = "cloud_config.yaml.tmpl"
    count = "${length(split(",", var.availability_zones))}"

    vars {
        aws_region = "${var.aws_region}"
        vpc_cidr_range = "172.33.0.0/16"
        # TODO: verify mappings are created between public & private subnets in the same AZ
        private_route_table_id = "${element(split(",", terraform_remote_state.vpc.output.private_route_table_ids), count.index)}"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "main" {
    count = "${length(split(",", var.availability_zones))}"

    image_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.main.id}"
    key_name = "${var.ec2_key_name}"
    security_groups = [ "${split(",", terraform_remote_state.vpc.output.subnet_egress_nat_instances_sg_id)}" ]
    user_data = "${element(template_file.cloud_config.*.rendered, count.index)}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "main" {
    name = "${var.stack_name}-subnet_egress_nat_asg-${element(split(",", terraform_remote_state.vpc.output.public_subnets), count.index)}"
    count = "${length(split(",", var.availability_zones))}"

    availability_zones = [ "${element(split(",", var.availability_zones), count.index)}" ]
    vpc_zone_identifier = [ "${element(split(",", terraform_remote_state.vpc.output.public_subnets), count.index)}" ]
    launch_configuration = "${element(aws_launch_configuration.main.*.id, count.index)}"

    max_size = "2"
    min_size = "1"
    desired_capacity = "1"
    health_check_grace_period = "300"
    health_check_type = "EC2"
    default_cooldown = "300"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_instance_profile" "main" {
    name = "subnet_egress_nat_instance_profile"
    path = "/${var.stack_name}/"
    roles = ["${aws_iam_role.main.name}"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role" "main" {
    name = "subnet_egress_nat_role"
    path = "/${var.stack_name}/"
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

resource "aws_iam_policy" "main" {
    name = "subnet_egress_nat_policy"
    path = "/${var.stack_name}/"
    # description = "My test policy"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "ec2:CreateRoute",
        "ec2:ReplaceRoute",
        "ec2:ModifyInstanceAttribute"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_policy_attachment" "main" {
    name = "subnet_egress_nat_policy_attachment"
    roles = ["${aws_iam_role.main.name}"]
    policy_arn = "${aws_iam_policy.main.arn}"

    lifecycle {
        create_before_destroy = true
    }
}