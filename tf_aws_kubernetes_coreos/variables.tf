variable "etcd_discovery_uri" {}
variable "admin_key_name" {}
variable "sg" {}
variable "region" {}
variable "leaders-coreos_channel" {
  default = "stable"
}
variable "leaders-availability_zones" {}
variable "leaders-az-subnets" {}

variable "follower-coreos_channel" {
  default = "stable"
}
variable "follower-ami_id" {}
variable "follower-availability_zones" {}
variable "follower-az-subnets" {}

variable "leaders-cluster_size" {
   default = 3
}
variable "followers-cluster_size" {
   default = 2
}
variable "leaders-instance_type" {
    default = "m3.large"
}
variable "followers-instance_type" {
    default = "m3.large"
}
variable "leaders-launch_config_name" {
    default = "kubernetes-leaders"
}
variable "followers-launch_config_name" {
    default = "kubernetes-followers"
}


variable "primary-az" {}
variable "secondary-az" {}
variable "primary-az-subnet" {}
variable "secondary-az-subnet" {}
