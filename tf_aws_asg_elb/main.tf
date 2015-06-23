provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_launch_configuration" "main" {
    name = "${var.launch_config_name}"
    image_id = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    iam_instance_profile = "${var.iam_instance_profile}"
    key_name = "${var.key_name}"
    security_groups = [ "${split(\",\", var.security_groups)}" ]
    user_data = "${var.user_data}"
    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "main" {
    depends_on = [ "aws_launch_configuration.main" ]
    name = "${var.asg_name}"

    availability_zones = [ "${split(\",\", var.availability_zones)}" ]
    vpc_zone_identifier = [ "${split(\",\", var.subnet_ids)}" ]

    launch_configuration = "${aws_launch_configuration.main.id}"

    max_size = "${var.asg_max_size}"
    min_size = "${var.asg_min_size}"
    desired_capacity = "${var.asg_desired_capacity}"
    health_check_grace_period = "${var.health_check_grace_period}"
    health_check_type = "${var.health_check_type}"
    default_cooldown = "${var.default_cooldown}"
    load_balancers = [ "${var.load_balancer_name}" ]
}
