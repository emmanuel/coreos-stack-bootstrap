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
# These are alpha channel, release 494.0.0
variable "amis" {
  default = {
    eu-central-1 = "ami-12ae980f"
    ap-northeast-1 = "ami-9d60599c"
    sa-east-1 = "ami-23ca7c3e"
    ap-southeast-2 = "ami-afb9d695"
    ap-southeast-1 = "ami-0cebc85e"
    us-east-1 = "ami-3e058d56"
    us-west-2 = "ami-b14f0481"
    us-west-1 = "ami-f97264bc"
    eu-west-1 = "ami-1c47f26b"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
