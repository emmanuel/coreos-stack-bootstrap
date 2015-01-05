variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instance_aws_access_key" {}
variable "instance_aws_secret_key" {}
variable "etcd_discovery_url" {}
variable "environment" {
  default = "test"
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
    eu-central-1 = "ami-ace3d3b1"
    ap-northeast-1 = "ami-9a0f1b9b"
    sa-east-1 = "ami-ebb406f6"
    ap-southeast-2 = "ami-a3325899"
    ap-southeast-1 = "ami-2f644d7d"
    us-east-1 = "ami-4205702a"
    us-west-2 = "ami-3fdc8e0f"
    us-west-1 = "ami-cfc5d98a"
    eu-west-1 = "ami-a41590d3"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
variable "vpc_zone_identifier" {
  default = "vpc-9111f3f4"
}
variable "aws_sns_topic_autoscaling_events_arn" {
  default = "arn:aws:sns:us-west-2:731703850786:autoscaling-events"
}
