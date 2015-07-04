output "availability_zones" {
  value = "${var.azs}"
}

output "private_subnets" {
  value = "${module.vpc.private_subnets}"
}

output "public_subnets" {
  value = "${module.vpc.public_subnets}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "cluster_members_sg_id" {
  value = "${aws_security_group.cluster_members.id}"
}

output "subnet_egress_nat_instances_sg_id" {
  value = "${aws_security_group.subnet-egress-nat-instances.id}"
}

output "bastion_instances_sg_id" {
  value = "${aws_security_group.bastion-instances.id}"
}
