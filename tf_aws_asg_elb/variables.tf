variable "launch_config_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "iam_instance_profile" {}
variable "key_name" {}

variable "security_groups" {}

variable "user_data" {
  description = "The user_data content for the instances"
}

// Auto-Scaling Group
variable "asg_name" {}
variable "asg_max_size" {
  description = "The maximum number of instances the ASG should maintain"
  # default = "${var.asg_desired_capacity + 1}"
}
variable "asg_min_size" {
  description = "The minimum number of instances the ASG should maintain"
}
variable "asg_desired_capacity" {
  description = "The number of instances we want in the ASG"
}

variable "health_check_grace_period" {
  description = "Number of seconds for a health check to time out"
  default = 300
}
variable "default_cooldown" {
  description = "Number of seconds to wait between auto-scaling events"
  default = 300
}
variable "health_check_type" {
  default = "ELB"
  //Types available are:
  // - ELB
  // - EC2
  // * http://docs.aws.amazon.com/cli/latest/reference/autoscaling/create-auto-scaling-group.html#options
}

variable "load_balancer_name" {}

// Our template assumes a comma-separated list of AZs and VPC subnet IDs for them
variable "availability_zones" {
  description = "Availability Zones to launch instances into"
}

variable "subnet_ids" {
  description = "VPC subnet IDs for AZs"
}

// Variables for providers used in this module
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
