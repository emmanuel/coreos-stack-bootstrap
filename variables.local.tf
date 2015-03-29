# defined in visible.tfvars
variable "aws_security_group_visible_elb_sg_id" {}
variable "aws_tag_value_team" {}
variable "aws_tag_value_cost_center" {}

variable "aws_instance_type" {
  default = "m3.large"
}
