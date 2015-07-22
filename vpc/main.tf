provider "aws" {
    region = "${var.aws_region}"
}

# Thanks! github.com/terraform-community-modules/tf_aws_vpc
module "vpc" {
    source = "../tf_aws_vpc"

    name = "innovation-platform-vpc-dev"

    cidr = "172.33.0.0/16"
    private_subnets = "172.33.1.0/24,172.33.2.0/24,172.33.3.0/24"
    public_subnets = "172.33.101.0/24,172.33.102.0/24,172.33.103.0/24"

    availability_zones = "${var.availability_zones}"
}

resource "aws_security_group" "cluster_members" {
    name = "${module.vpc.vpc_id}-cluster_members"
    description = "Allow all traffic between cluster members"
    vpc_id = "${module.vpc.vpc_id}"

    tags {
        Name = "cluster_members"
    }
}

resource "aws_security_group_rule" "cluster_members_allow_all_intra_cluster_traffic_ingress" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.cluster_members.id}"
    self = true
}

resource "aws_security_group_rule" "cluster_members_allow_all_intra_cluster_traffic_egress" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.cluster_members.id}"
    self = true
}

resource "aws_security_group_rule" "cluster_members_allow_bastion_instances_ssh_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = "${aws_security_group.cluster_members.id}"
    source_security_group_id = "${aws_security_group.bastion_instances.id}"
}

resource "aws_security_group" "bastion_instances" {
    name = "${module.vpc.vpc_id}-bastion_instances"
    description = "Includes all bastion instances"
    vpc_id = "${module.vpc.vpc_id}"

    tags {
        Name = "bastion_instances"
    }
}

resource "aws_security_group_rule" "bastion_instances_allow_cidr_block_ssh_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

    security_group_id = "${aws_security_group.bastion_instances.id}"
}

resource "aws_security_group_rule" "bastion_instances_allow_ssh_egress_to_cluster_members" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = "${aws_security_group.bastion_instances.id}"
    source_security_group_id = "${aws_security_group.cluster_members.id}"
}

resource "aws_security_group" "subnet_egress_nat_instances" {
    name = "${module.vpc.vpc_id}-subnet_egress_nat_instances"
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
        Name = "subnet_egress_nat_instances"
    }
}
