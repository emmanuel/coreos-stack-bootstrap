# defined in keys.tfvars
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "instance_aws_access_key" {}
variable "instance_aws_secret_key" {}

# defined in cluster_id.tfvars
variable "environment" {}
variable "etcd_discovery_url" {}

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
    eu-central-1 = "ami-8eb58693"
    ap-northeast-1 = "ami-00958f01"
    sa-east-1 = "ami-e3b609fe"
    ap-southeast-2 = "ami-6b2c5b51"
    ap-southeast-1 = "ami-da9cb688"
    us-east-1 = "ami-aa91dcc2"
    us-west-2 = "ami-f7a5fec7"
    us-west-1 = "ami-aa6f74ef"
    eu-west-1 = "ami-d1c44da6"
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
