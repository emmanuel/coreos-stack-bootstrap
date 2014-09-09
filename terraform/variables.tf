variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "etcd_discovery_url" {}

variable "aws_instance_type" {
  default = "m3.medium"
}
variable "aws_region" {
  default = "us-west-2"
}
variable "environment" {
  default = "test"
}

# The net block (CIDR) that SSH is available to.
variable "allow_ssh_from" {
  default = "0.0.0.0/0"
}

variable "amis" {
  default = {
    ap-northeast-1 = "ami-4d6b484c"
    sa-east-1 = "ami-455af158"
    ap-southeast-2 = "ami-6553335f"
    ap-southeast-1 = "ami-101e3b42"
    us-east-1 = "ami-a63a9bce"
    us-west-2 = "ami-99a0e6a9"
    us-west-1 = "ami-313c3274"
    eu-west-1 = "ami-56be6421"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id" {
  default = "Z23E6ZIBKPSZQE"
}
