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
    ap-northeast-1 = "ami-59371558"
    sa-east-1 = "ami-f51ab1e8"
    ap-southeast-2 = "ami-1b98f821"
    ap-southeast-1 = "ami-0cab8e5e"
    us-east-1 = "ami-c4fe5cac"
    us-west-2 = "ami-25276615"
    us-west-1 = "ami-d7999792"
    eu-west-1 = "ami-9cff5aeb"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
