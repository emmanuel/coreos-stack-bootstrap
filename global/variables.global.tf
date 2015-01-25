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
    eu-central-1 = "ami-3c3d0e21"
    ap-northeast-1 = "ami-be5649bf"
    sa-east-1 = "ami-35f14d28"
    ap-southeast-2 = "ami-a9d0a593"
    ap-southeast-1 = "ami-8e301bdc"
    us-east-1 = "ami-e6a8d38e"
    us-west-2 = "ami-db1940eb"
    us-west-1 = "ami-b60b12f3"
    eu-west-1 = "ami-ef63e198"
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
