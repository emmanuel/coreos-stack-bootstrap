provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

module "vpc" {
    source = "github.com/terraform-community-modules/tf_aws_vpc"

    name = "innovation-platform-vpc"

    cidr = "172.33.0.0/16"
    private_subnets = "172.33.1.0/24,172.33.2.0/24,172.33.3.0/24"
    public_subnets = "172.33.101.0/24,172.33.102.0/24,172.33.103.0/24"

    azs = "${var.azs}"
}
