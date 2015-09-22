resource "aws_route53_record" "bastion" {
    zone_id = "${var.route53_zone_id}"
    name = "${var.ssh_dns_name}"
    type = "A"

    alias {
        name = "${aws_elb.bastion.dns_name}"
        zone_id = "${aws_elb.bastion.zone_id}"
        evaluate_target_health = true
    }
}

resource "aws_elb" "bastion" {
    name = "${aws_vpc.main.id}-bastion-elb"
    subnets = [ "${aws_subnet.public.*.id}" ]
    security_groups = [ "${aws_security_group.bastion_elb.id}" ]

    listener {
        instance_port = 22
        instance_protocol = "tcp"
        lb_port = 2222
        lb_protocol = "tcp"
    }

    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 10
        timeout = 3
        target = "TCP:22"
        interval = 15
    }

    idle_timeout = 300

    tags {
        Name = "bastion-elb"
    }
}
