variable "etcd_discovery_url" {
  default = "https://discovery.etcd.io/blah"
}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_instance_type" {
  default = "m3.medium"
}
variable "aws_region" {
  default = "us-west-2"
}
variable "environment" {
  default = "test"
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}

# The net block (CIDR) that SSH is available to.
variable "allow_ssh_from" {
  default = "0.0.0.0/0"
}

variable "amis" {
  default = {
    ap-northeast-1 = "ami-df1a3cde"
    sa-east-1 = "ami-41d47f5c"
    ap-southeast-2 = "ami-99d5b4a3"
    ap-southeast-1 = "ami-fad78da8"
    us-east-1 = "ami-7cbc1914"
    us-west-2 = "ami-2f70371f"
    us-west-1 = "ami-0dccc348"
    eu-west-1 = "ami-a2835bd5"
  }
}
