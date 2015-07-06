variable "aws_region" {}

variable "stack_name" {}
variable "availability_zones" {}
variable "ec2_instance_type" {}
variable "coreos_ami_id" {}
variable "ec2_key_name" {}
variable "etcd_discovery_url" {}

variable "autoscaling_group_health_check_type" {
    default = "EC2"
}
variable "health_check_grace_period" {
    default = 300
}
variable "default_cooldown" {
    default = 300
}
