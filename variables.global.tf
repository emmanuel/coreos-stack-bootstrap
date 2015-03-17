# defined in keys.tfvars
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instance_aws_access_key" {}
variable "instance_aws_secret_key" {}

# defined in cluster_id.tfvars
variable "stack_name" {}
variable "etcd_discovery_url" {}
variable "coreos_ami" {}

variable "aws_region" {
  default = "us-west-2"
}

# The net block (CIDR) that SSH is available to.
variable "allow_ssh_from" {
  default = "0.0.0.0/0"
}

variable "aws_ec2_key_name" {}
variable "aws_route53_zone_id" {}
variable "aws_vpc_zone_identifier" {}
variable "aws_iam_server_certificate_arn" {}
