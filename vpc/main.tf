provider "aws" {
    region = "${var.aws_region}"
}

module "vpc" {
    source = "github.com/terraform-community-modules/tf_aws_vpc"

    name = "innovation-platform-vpc-dev"

    cidr = "172.33.0.0/16"
    private_subnets = "172.33.1.0/24,172.33.2.0/24,172.33.3.0/24"
    public_subnets = "172.33.101.0/24,172.33.102.0/24,172.33.103.0/24"

    azs = "${var.azs}"
}

resource "aws_security_group" "cluster_members" {
    name = "${module.vpc.vpc_id}-cluster_members_allow_all_intra_cluster_traffic"
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
    }
}

resource "aws_security_group" "bastion-instances" {
    name = "${module.vpc.vpc_id}-bastion_instances_allow_ssh_ingress_to_cluster_members"
    description = "Allow SSH ingress traffic to bastion instances"
    vpc_id = "${module.vpc.vpc_id}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = [ "${aws_security_group.cluster_members.id}" ]
    }

    tags {
        Name = "allow_bastion_hosts_to_ssh_to_cluster_members_sg"
    }
}

resource "aws_security_group" "subnet-egress-nat-instances" {
    name = "${module.vpc.vpc_id}-subnet-egress-nat-instances-allow-egress"
    description = "Allow egress traffic from DMZ instances"
    vpc_id = "${module.vpc.vpc_id}"

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
