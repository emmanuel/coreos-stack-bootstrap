# defined in visible/visible.tfvars
# variable "aws_elb_name_etcd_visible" {}
# variable "aws_security_group_elb_etcd_visible_id" {}
variable "aws_elb_name_vulcand_visible" {}
variable "aws_security_group_elb_vulcand_visible_id" {}
variable "aws_elb_name_gtin_visible" {}
variable "aws_security_group_elb_gtin_visible_id" {}

variable "aws_instance_type" {
  default = "m3.large"
}
