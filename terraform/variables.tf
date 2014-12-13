variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instance_aws_access_key" {}
variable "instance_aws_secret_key" {}
variable "etcd_discovery_url" {}
variable "environment" {
  default = "test"
}

variable "aws_instance_type_control" {
  default = "m3.large"
}
variable "aws_instance_type_deis" {
  default = "m3.large"
}
variable "aws_region" {
  default = "us-west-2"
}

# The net block (CIDR) that SSH is available to.
variable "allow_ssh_from" {
  default = "0.0.0.0/0"
}

# get updates at https://s3.amazonaws.com/coreos.com/dist/aws/coreos-alpha-hvm.template
# These are alpha channel, HVM virtualization
variable "amis" {
  default = {
    eu-central-1 = "ami-10c0f10d"
    ap-northeast-1 = "ami-da6566db"
    sa-east-1 = "ami-99da6a84"
    ap-southeast-2 = "ami-a9c8a193"
    ap-southeast-1 = "ami-957559c7"
    us-east-1 = "ami-f669f29e"
    us-west-2 = "ami-d9f8afe9"
    us-west-1 = "ami-ad0516e8"
    eu-west-1 = "ami-f4853883"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
