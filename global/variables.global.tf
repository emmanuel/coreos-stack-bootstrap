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
    eu-central-1 = "ami-1a97a607"
    ap-northeast-1 =  "ami-96e2ef97"
    sa-east-1 = "ami-5d56e640"
    ap-southeast-2 =  "ami-dd4a22e7"
    ap-southeast-1 = "ami-9fd6facd"
    us-east-1 =  "ami-1299fe7a"
    us-west-2 = "ami-c71d4cf7"
    us-west-1 =  "ami-37766472"
    eu-west-1 = "ami-748b3403"
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
