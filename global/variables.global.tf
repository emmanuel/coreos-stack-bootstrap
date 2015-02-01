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

# CoreOS AMIs. These are alpha channel, HVM virtualization
# from: https://s3.amazonaws.com/coreos.com/dist/aws/coreos-alpha-hvm.template
variable "coreos_amis" {
  default = {
    eu-central-1 = "ami-da0132c7"
    ap-northeast-1 = "ami-fa849afb"
    sa-east-1 = "ami-239a263e"
    ap-southeast-2 = "ami-fb0074c1"
    ap-southeast-1 = "ami-e0ba91b2"
    us-east-1 = "ami-6670340e"
    us-west-2 = "ami-3dc49d0d"
    us-west-1 = "ami-ee938aab"
    eu-west-1 = "ami-5539b422"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
variable "aws_route53_zone_id_cloud_nlab_io" {
  default = "Z23E6ZIBKPSZQE"
}
variable "aws_vpc_zone_identifier" {
  default = "vpc-9111f3f4"
}
variable "aws_sns_topic_autoscaling_events_arn" {
  default = "arn:aws:sns:us-west-2:731703850786:autoscaling-events"
}
