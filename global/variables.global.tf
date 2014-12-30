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
    eu-central-1 =  "ami-d83e0ec5"
    ap-northeast-1  = "ami-368d8537"
    sa-east-1 = "ami-3f7ac922"
    ap-southeast-2  =  "ami-315a310b"
    ap-southeast-1 =  "ami-0f7f515d"
    us-east-1  = "ami-489af520"
    us-west-2 = "ami-f15d0ec1"
    us-west-1  = "ami-e5fde0a0"
    eu-west-1 = "ami-92c17ae5"
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
variable "aws_sns_topic_contol_autoscaling_events_arn" {
  default = "arn:aws:sns:us-west-2:731703850786:control-autoscaling-events"
}
