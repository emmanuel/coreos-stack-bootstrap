output "availability_zones" {
  value = "${var.availability_zones}"
}

output "private_subnets" {
  value = "${terraform_remote_state.vpc.private_subnets}"
}

output "public_subnets" {
  value = "${terraform_remote_state.vpc.public_subnets}"
}

output "vpc_id" {
  value = "${terraform_remote_state.vpc.vpc_id}"
}
