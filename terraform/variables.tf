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

# get updates at https://s3.amazonaws.com/coreos.com/dist/aws/coreos-alpha-hvm.template
variable "amis" {
  default = {
    ap-northeast-1 = "ami-19210d18"
    sa-east-1 = "ami-e9ba10f4"
    ap-southeast-2 = "ami-1706652d"
    ap-southeast-1 = "ami-26250174"
    us-east-1 = "ami-0a6ac562"
    us-west-2 = "ami-49febf79"
    us-west-1 = "ami-09c8c14c"
    eu-west-1 = "ami-5070d427"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
