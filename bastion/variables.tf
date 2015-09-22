variable "aws_region" {}

variable "ec2_key_name" {}
variable "ec2_instance_type" {}
variable "coreos_ami_id" {}
variable "stack_name" {}

variable "route53_zone_id" {}
variable "ssh_dns_name" {}

variable "availability_zones" {}

variable "autoscaling_group_health_check_type" {
    default = "EC2"
}
variable "health_check_grace_period" {
    default = 300
}
variable "default_cooldown" {
    default = 300
}
