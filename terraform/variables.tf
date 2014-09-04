variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_instance_type" {
  default = "m3.medium"
}
variable "aws_region" {
  default = "us-west-2"
}
variable "environment" {
  default = "test"
}

# The net block (CIDR) that SSH is available to.
variable "AllowSSHFrom" {
  default = "0.0.0.0/0"
}

variable "amis" {
  default = {
    #ap-northeast-1 = "ami-fbf3a1fa"
    #sa-east-1 = "ami-edab02f0"
    #ap-southeast-2 = "ami-35d1b60f"
    #ap-southeast-1 = "ami-2a075f78"
    #us-east-1 = "ami-88e52ce0"
    us-west-2 = "ami-d52462e5"
    #us-west-1 = "ami-13eeed56"
    #eu-west-1 = "ami-7de4350a"
  }
}
variable "aws_ec2_keypair" {
  default = "coreos-beta"
}
