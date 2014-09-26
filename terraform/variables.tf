variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instance_aws_access_key" {}
variable "instance_aws_secret_key" {}
variable "etcd_discovery_url" {}
variable "environment" {
  default = "test"
}

variable "aws_instance_type" {
  default = "m3.medium"
}
variable "aws_region" {
  default = "us-west-2"
}

# The net block (CIDR) that SSH is available to.
variable "allow_ssh_from" {
  default = "0.0.0.0/0"
}

# get updates at https://s3.amazonaws.com/coreos.com/dist/aws/coreos-alpha-hvm.template
variable "amis" {
  default = {
    ap-northeast-1 = "ami-9794bd96"
    sa-east-1 = "ami-3319b32e"
    ap-southeast-2 = "ami-d3d4b7e9"
    ap-southeast-1 = "ami-2c486f7e"
    us-east-1 = "ami-fe60d496"
    us-west-2 = "ami-01de9d31"
    us-west-1 = "ami-2981896c"
    eu-west-1 = "ami-ec98399b"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
