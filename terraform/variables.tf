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
    ap-northeast-1 = "ami-c93504c8"
    sa-east-1 = "ami-698d3974"
    ap-southeast-2 = "ami-05b0dd3f"
    ap-southeast-1 = "ami-925071c"
    us-east-1 = "ami-50db6138"
    us-west-2 = "ami-75410e45"
    us-west-1 = "ami-830411c6"
    eu-west-1 = "ami-7cb9160b"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
