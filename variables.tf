variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "ec2_key_name" {}
variable "ec2_instance_type" {}
variable "stack_name" {}
variable "coreos_ami_id" {}

variable "autoscaling_group_health_check_type" {
    default = "EC2"
}
variable "health_check_grace_period" {
    default = 300
}
variable "default_cooldown" {
    default = 300
}

variable "availability_zones" {}
variable "etcd_discovery_url" {}
