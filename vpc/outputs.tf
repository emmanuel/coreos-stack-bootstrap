output "availability_zones" {
    value = "${var.availability_zones}"
}

output "private_subnets" {
    value = "${module.vpc.private_subnets}"
}

output "public_subnets" {
    value = "${module.vpc.public_subnets}"
}

output "private_route_table_ids" {
    value = "${module.vpc.private_route_table_ids}"
}

output "public_route_table_id" {
    value = "${module.vpc.public_route_table_id}"
}

output "vpc_id" {
    value = "${module.vpc.vpc_id}"
}

output "cluster_members_sg_id" {
    value = "${aws_security_group.cluster_members.id}"
}

output "subnet_egress_nat_instances_sg_id" {
    value = "${aws_security_group.subnet_egress_nat_instances.id}"
}

output "bastion_instances_sg_id" {
    value = "${aws_security_group.bastion_instances.id}"
}
