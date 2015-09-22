resource "aws_security_group" "cluster_members" {
    name = "${aws_vpc.main.id}-cluster_members"
    description = "Allow all traffic between cluster members"
    vpc_id = "${aws_vpc.main.id}"

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

resource "aws_security_group_rule" "cluster_members_allow_all_egress_traffic_to_subnet_egress_nat" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"

    security_group_id = "${aws_security_group.cluster_members.id}"
    source_security_group_id = "${aws_security_group.subnet_egress_nat_instances.id}"
}

resource "aws_security_group_rule" "cluster_members_allow_bastion_instances_ssh_ingress" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = "${aws_security_group.cluster_members.id}"
    source_security_group_id = "${aws_security_group.bastion_instances.id}"
}

resource "aws_security_group" "services_instances" {
    name = "${aws_vpc.main.id}-services_instances"
    description = "Includes all services instances"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "services_instances"
    }
}

resource "aws_security_group" "bastion_instances" {
    name = "${aws_vpc.main.id}-bastion_instances"
    description = "Includes all bastion instances"
    vpc_id = "${aws_vpc.main.id}"

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

resource "aws_security_group_rule" "bastion_instances_allow_ssh_ingress_from_elb" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    source_security_group_id = "${aws_security_group.bastion_elb.id}"
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

resource "aws_security_group_rule" "bastion_instances_allow_ssh_egress_to_subnet_egress_nat_instances" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"

    security_group_id = "${aws_security_group.bastion_instances.id}"
    source_security_group_id = "${aws_security_group.subnet_egress_nat_instances.id}"
}

resource "aws_security_group" "bastion_elb" {
    name = "${aws_vpc.main.id}-bastion_ingress-elb"
    description = "Allow SSH ingress traffic from ELB to bastion instances"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "bastion_ingress-elb"
    }
}

resource "aws_security_group_rule" "bastion_elb_allows_ssh_ingress_from_cidr_block" {
    type = "ingress"
    from_port = 2222
    to_port = 2222
    protocol = "tcp"

    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = "${aws_security_group.bastion_elb.id}"
}

resource "aws_security_group_rule" "bastion_elb_allows_ssh_egress_to_bastion_instances" {
    type = "egress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.bastion_instances.id}"
    security_group_id = "${aws_security_group.bastion_elb.id}"
}

resource "aws_security_group" "subnet_egress_nat_instances" {
    name = "${aws_vpc.main.id}-subnet_egress_nat_instances"
    description = "Allow egress traffic from DMZ instances"
    vpc_id = "${aws_vpc.main.id}"

    tags {
        Name = "subnet_egress_nat_instances"
    }
}

resource "aws_security_group_rule" "subnet_egress_nat_instances_allow_ingress_from_cluster_members" {
    type = "ingress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    source_security_group_id = "${aws_security_group.cluster_members.id}"
    security_group_id = "${aws_security_group.subnet_egress_nat_instances.id}"
}

resource "aws_security_group_rule" "subnet_egress_nat_instances_allow_egress_to_anywhere" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
    security_group_id = "${aws_security_group.subnet_egress_nat_instances.id}"
}

resource "aws_security_group_rule" "subnet_egress_nat_instances_allow_ssh_ingress_from_bastion_instances" {
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    source_security_group_id = "${aws_security_group.bastion_instances.id}"
    security_group_id = "${aws_security_group.subnet_egress_nat_instances.id}"
}
