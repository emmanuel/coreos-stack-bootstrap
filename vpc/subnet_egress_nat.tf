resource "aws_network_interface" "subnet_egress_nat" {
    count = "${length(split(",", var.availability_zones))}"

    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    security_groups = [ "${aws_security_group.subnet_egress_nat_instances.id}" ]
    source_dest_check = false
}

resource "aws_eip" "subnet_egress_nat" {
    count = "${length(split(",", var.availability_zones))}"

    network_interface = "${element(aws_network_interface.subnet_egress_nat.*.id, count.index)}"
    vpc = true
}
