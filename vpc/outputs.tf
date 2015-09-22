output "vpc_id" {
    value = "${aws_vpc.main.id}"
}

output "private_subnets" {
    value = "${join(",", aws_subnet.private.*.id)}"
}

output "public_subnets" {
    value = "${join(",", aws_subnet.public.*.id)}"
}

output "private_route_table_ids" {
    value = "${join(",", aws_route_table.private.*.id)}"
}

output "public_route_table_id" {
    value = "${aws_route_table.public.id}"
}

output "cluster_members_sg_id" {
    value = "${aws_security_group.cluster_members.id}"
}

output "bastion_instances_sg_id" {
    value = "${aws_security_group.bastion_instances.id}"
}

output "services_instances_sg_id" {
    value = "${aws_security_group.services_instances.id}"
}

output "subnet_egress_nat_instances_sg_id" {
    value = "${aws_security_group.subnet_egress_nat_instances.id}"
}

output "subnet_egress_nat_network_interfaces" {
    value = "${join(",", aws_network_interface.subnet_egress_nat.*.id)}"
}

output "internal_route53_zone_id" {
    value = "${aws_route53_zone.internal.zone_id}"
}

output "bastion_ssh_dns_name" {
  value = "${var.ssh_dns_name}"
}

output "bastion_elb_dns" {
  value = "${aws_elb.bastion.dns_name}"
}

output "bastion_elb_id" {
  value = "${aws_elb.bastion.id}"
}
