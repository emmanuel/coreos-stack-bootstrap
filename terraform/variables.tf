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
    eu-central-1 = "ami-94231289"
    ap-northeast-1 = "ami-d8999dd9"
    sa-east-1 = "ami-7fa41562"
    ap-southeast-2 = "ami-e3dfb1d9"
    ap-southeast-1 = "ami-7b98ba29"
    us-east-1 = "ami-0215876a"
    us-west-2 = "ami-d72377e7"
    us-west-1 = "ami-a5adbce0"
    eu-west-1 = "ami-d8e858af"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
