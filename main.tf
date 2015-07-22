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

resource "terraform_remote_state" "subnet-egress-nat" {
    backend = "s3"
    config {
        bucket = "tf-remote-state"
        key = "innovation-platform-dev/subnet-egress-nat/terraform.tfstate"
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
