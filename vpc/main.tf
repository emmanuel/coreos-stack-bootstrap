provider "aws" {
    region = "${var.aws_region}"
}

# Thanks! github.com/terraform-community-modules/tf_aws_vpc
resource "aws_vpc" "main" {
    cidr_block = "${var.vpc_cidr_range}"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags {
        Name = "${var.vpc_name}"
    }
}

resource "aws_internet_gateway" "vpc" {
    vpc_id = "${aws_vpc.main.id}"
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.vpc.id}"
    }
    tags {
        Name = "${var.vpc_name}-public"
    }
}

resource "aws_route_table" "private" {
    count = "${length(split(",", var.vpc_private_subnets))}"
    vpc_id = "${aws_vpc.main.id}"
    route {
        cidr_block = "0.0.0.0/0"
        network_interface_id = "${element(aws_network_interface.subnet_egress_nat.*.id, count.index)}"
    }
    tags {
        Name = "${var.vpc_name}-private-${element(split(",", var.availability_zones), count.index)}"
    }
}

resource "aws_subnet" "private" {
    count = "${length(split(",", var.vpc_private_subnets))}"
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${element(split(",", var.vpc_private_subnets), count.index)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"

    tags {
        Name = "${var.vpc_name}-private-${element(split(",", var.availability_zones), count.index)}"
    }
}

resource "aws_subnet" "public" {
    count = "${length(split(",", var.vpc_public_subnets))}"
    vpc_id = "${aws_vpc.main.id}"
    cidr_block = "${element(split(",", var.vpc_public_subnets), count.index)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"
    tags {
        Name = "${var.vpc_name}-public-${element(split(",", var.availability_zones), count.index)}"
    }

    map_public_ip_on_launch = true
}

resource "aws_route_table_association" "private" {
    count = "${length(split(",", var.vpc_private_subnets))}"
    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
    count = "${length(split(",", var.vpc_private_subnets))}"
    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route53_zone" "internal" {
    name = "cloud.nlab.io"
    comment = "DNS zone for internal split-horizon records"
    vpc_id = "${aws_vpc.main.id}"
    vpc_region = "${var.aws_region}"

    tags {
        Name = "vpc_internal_zone"
        Environment = "dev"
    }
}
