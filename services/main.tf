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

resource "aws_autoscaling_group" "services" {
    name = "${terraform_remote_state.vpc.output.vpc_id}-services-asg"

    availability_zones = [ "${split(",", var.availability_zones)}" ]
    vpc_zone_identifier = [ "${split(",", terraform_remote_state.vpc.output.private_subnets)}" ]
    launch_configuration = "${aws_launch_configuration.services.id}"
    load_balancers = [ "${aws_elb.services_ingress.id}" ]

    max_size = "4"
    min_size = "3"
    desired_capacity = "3"
    health_check_grace_period = "300"
    health_check_type = "EC2"
    default_cooldown = "120"

    tag {
        key = "Name"
        value = "services"
        propagate_at_launch = true
    }

    tag {
        key = "StackName"
        value = "${var.stack_name}"
        propagate_at_launch = true
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_launch_configuration" "services" {
    # name = "${terraform_remote_state.vpc.output.vpc_id}-services-launch_config"
    image_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.services.name}"
    key_name = "${var.ec2_key_name}"
    security_groups = [
        "${terraform_remote_state.vpc.output.cluster_members_sg_id}",
        "${terraform_remote_state.vpc.output.services_instances_sg_id}"
    ]
    user_data = "${template_file.cloud_config.rendered}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "template_file" "cloud_config" {
    filename = "cloud_config.yaml.tmpl"

    vars {
        aws_region = "${var.aws_region}"
        etcd_discovery_url = "${var.etcd_discovery_url}"
        kube_apiserver_dns_name = "${var.stack_name}-kube-apiserver.cloud.nlab.io"
        container_cidr_range = "172.31.0.0/16"
        cluster_dns_server_ip = "172.30.255.10"
        internal_route53_zone_id = "${terraform_remote_state.vpc.output.internal_route53_zone_id}"
        # cluster_domain = "cluster.local"
        #
        # vpc_cidr_range = "172.20.0.0/16"
        # subnet_private_az1 = "172.20.0.0/24"
        # subnet_private_az2 = "172.20.1.0/24"
        # subnet_private_az3 = "172.20.2.0/24"
        # host_private_az1 = "172.20.0.1"
        # host_private_az2 = "172.20.1.1"
        # host_private_az3 = "172.20.2.1"
        # subnet_public_az1 = "172.20.200.0/24"
        # subnet_public_az2 = "172.20.201.0/24"
        # subnet_public_az3 = "172.20.202.0/24"
        # host_public_az1 = "172.20.200.1"
        # host_public_az2 = "172.20.201.1"
        # host_public_az3 = "172.20.202.1"
        # container_host_subnet_1 = "172.31.0.0/24"
        # container_1 = "172.31.0.1"
        # container_host_subnet_2 = "172.31.1.0/24"
        # container_2 = "172.31.1.1"
        #
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "services_instances_allow_ssh_ingress_from_elb" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    source_security_group_id = "${aws_security_group.services_ingress_elb.id}"
    security_group_id = "${terraform_remote_state.vpc.output.services_instances_sg_id}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group" "services_ingress_elb" {
    name = "${terraform_remote_state.vpc.output.vpc_id}-services_ingress-elb"
    description = "Allow SSH ingress traffic from ELB to bastion instances"
    vpc_id = "${terraform_remote_state.vpc.output.vpc_id}"

    tags {
        Name = "services_ingress_elb_sg"
    }

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "services_ingress_elb_allows_ssh_ingress_from_cidr_block" {
    type = "ingress"
    from_port = 2222
    to_port = 2222
    protocol = "tcp"

    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = "${aws_security_group.services_ingress_elb.id}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_security_group_rule" "services_ingress_elb_allows_ssh_egress_to_cluster_members" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = "${terraform_remote_state.vpc.output.services_instances_sg_id}"
    security_group_id = "${aws_security_group.services_ingress_elb.id}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_elb" "services_ingress" {
    name = "${terraform_remote_state.vpc.output.vpc_id}-services-b"
    subnets = [ "${split(",", terraform_remote_state.vpc.output.private_subnets)}" ]
    security_groups = [ "${aws_security_group.services_ingress_elb.id}" ]

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
        Name = "services_ingress-elb"
    }

    lifecycle {
        create_before_destroy = true
    }
}

# resource "aws_route53_record" "bastion" {
#     zone_id = "${var.route53_zone_id}"
#     name = "${var.ssh_dns_name}"
#     type = "A"
#
#     alias {
#         name = "${aws_elb.bastion.dns_name}"
#         zone_id = "${aws_elb.bastion.zone_id}"
#         evaluate_target_health = true
#     }
# }

resource "aws_iam_instance_profile" "services" {
    name = "services_instance_profile"
    path = "/${terraform_remote_state.vpc.output.vpc_id}/"
    roles = ["${aws_iam_role.services.name}"]

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role" "services" {
    name = "services_role"
    path = "/${terraform_remote_state.vpc.output.vpc_id}/"
    assume_role_policy = <<JSON
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
JSON

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role_policy" "cluster_members" {
    name = "cluster_members_role_policy"
    role = "${aws_iam_role.services.id}"
    policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": "autoscaling:DescribeAutoScalingGroups",
        "Resource": "*"
    }
  ]
}
JSON

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role_policy" "flannel" {
    name = "flannel_role_policy"
    role = "${aws_iam_role.services.id}"
    policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "ec2:CreateRoute",
            "ec2:DeleteRoute",
            "ec2:ReplaceRoute"
        ],
        "Resource": [
            "*"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2:DescribeRouteTables",
            "ec2:DescribeInstances"
        ],
        "Resource": "*"
    }
  ]
}
JSON

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_iam_role_policy" "internal_dns" {
    name = "internal_dns_role_policy"
    role = "${aws_iam_role.services.id}"
    policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": ["route53:ChangeResourceRecordSets"],
        "Resource": "arn:aws:route53:::hostedzone/${terraform_remote_state.vpc.output.internal_route53_zone_id}"
    }
  ]
}
JSON

    lifecycle {
        create_before_destroy = true
    }
}

# resource "aws_route53_record" "etcd" {
#     zone_id = "${terraform_remote_state.vpc.output.internal_route53_zone_id}"
#     name = "${var.stack_name}-etcd.${var.dns_domain_root}"
#     type = "A"
#
#     alias {
#         name = "${aws_elb.services.dns_name}"
#         zone_id = "${aws_elb.services.zone_id}"
#         evaluate_target_health = true
#     }
#
#     lifecycle {
#         create_before_destroy = true
#     }
# }

# resource "aws_route53_record" "k8s_apiserver" {
#     zone_id = "${terraform_remote_state.vpc.output.internal_route53_zone_id}"
#     name = "${var.stack_name}-k8s-apiserver.${var.dns_domain_root}"
#     type = "A"
#
#     alias {
#         name = "${aws_elb.services.dns_name}"
#         zone_id = "${aws_elb.services.zone_id}"
#         evaluate_target_health = true
#     }
#
#     lifecycle {
#         create_before_destroy = true
#     }
# }
