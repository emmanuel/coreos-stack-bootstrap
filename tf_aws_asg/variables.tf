variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vpc_id" {
    default = ""
}

variable "launch_config_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "iam_instance_profile" {}
variable "key_name" {}

variable "security_group_ids" {}

variable "user_data" {
  description = "The user_data content for the instances"
}

variable "load_balancer_name" {
    default = "xktbz-test-elb"
}


// Auto-Scaling Group
variable "autoscaling_group_name" {}
variable "autoscaling_group_max_size" {
  description = "The maximum number of instances the ASG should maintain"
}
variable "autoscaling_group_min_size" {
  description = "The minimum number of instances the ASG should maintain"
}
variable "autoscaling_group_desired_capacity" {
  description = "The number of instances we want in the ASG"
}

variable "health_check_grace_period" {
  description = "Number of seconds for a health check to time out"
  default = 300
}
variable "default_cooldown" {
  description = "Number of seconds to wait between auto-scaling events"
  default = 120
}
variable "health_check_type" {
  default = "EC2"
}

// Comma-separated list of AZs
variable "availability_zones" {
  description = "Availability Zones to launch instances into"
}

// omma-separated list of VPC subnet IDs corresponding to the above list of AZs
variable "subnet_ids" {
  description = "VPC subnet IDs for AZs"
}
