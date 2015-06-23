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

module "test-asg" {
    source = "tf_aws_asg"

    aws_region = "${var.aws_region}"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    vpc_id = "${module.vpc.vpc_id}"

    launch_config_name = "${var.stack_name}-test-launch_config"
    ami_id = "${var.coreos_ami_id}"
    instance_type = "${var.ec2_instance_type}"
    iam_instance_profile = "${aws_iam_instance_profile.test_profile.name}"
    key_name = "${var.ec2_key_name}"

    security_group_ids = "${aws_security_group.cluster_members.id}"

    user_data = ""

    autoscaling_group_name = "${var.stack_name}-test-asg"
    autoscaling_group_max_size = 5
    autoscaling_group_min_size = 3
    autoscaling_group_desired_capacity = 3
    health_check_grace_period = "${var.health_check_grace_period}"
    default_cooldown = "${var.default_cooldown}"
    health_check_type = "${var.health_check_type}"
    load_balancer_name = "${aws_elb.test-elb.name}"

    availability_zones = "${var.availability_zones}"
    subnet_ids = "${module.vpc.private_subnets}"
}

resource "aws_security_group" "test-elb_sg" {
    name = "${var.stack_name}-test-elb_sg"
    description = "Marker security group for test-elb"

    tags {
        Name = "test-elb_sg"
        StackName = "${var.stack_name}"
    }
}

resource "aws_elb" "test-elb" {
    name = "${var.stack_name}-test-elb"
    availability_zones = [ "${split(\",\", var.availability_zones)}" ]
    security_groups = [ "${aws_security_group.test-elb_sg.id}" ]

    listener {
        instance_port = 4001
        instance_protocol = "http"
        lb_port = 4001
        lb_protocol = "http"
    }

    # listener {
    #     instance_port = 8000
    #     instance_protocol = "http"
    #     lb_port = 443
    #     lb_protocol = "https"
    #     ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
    # }

    # health_check {
    #     healthy_threshold = 2
    #     unhealthy_threshold = 2
    #     timeout = 3
    #     target = "HTTP:7001/"
    #     interval = 30
    # }

    # instances = ["${aws_instance.foo.id}"]
    cross_zone_load_balancing = true
    idle_timeout = 60
    connection_draining = true
    connection_draining_timeout = 300

    tags {
        Name = "test-elb"
        StackName = "${var.stack_name}"
    }
}

resource "template_file" "test-cloud_config" {
    filename = "test.yaml.tmpl"

    vars {
        etcd_discovery_url = "${var.etcd_discovery_url}"
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
