# defined in visible.tfvars
variable "aws_elb_name_vulcand_visible" {}
variable "aws_security_group_elb_vulcand_visible_id" {}
variable "aws_tag_value_team" {}
variable "aws_tag_value_cost_center" {}

variable "aws_instance_type" {
  default = "m3.large"
}
