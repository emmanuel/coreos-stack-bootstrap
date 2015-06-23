provider "aws" {
    region = "${var.aws_region}"
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
}

# resource "template_file" "follower-cloud_config" {
#     filename = "test.tmpl"
#
#     vars {
#         hello = "goodnight"
#         world = "moon"
#     }
# }

module "test-asg" {
    source = "tf_aws_asg_elb"

    launch_config_name = "foo"
    ami_id = "${file(\"build/coreos_alpha_ami_id\")}"
    instance_type = "t2.small"
    # iam_instance_profile = "${file(\"build/iam_instance_profile\")}"
    iam_instance_profile = "bar"
    # key_name = "${file(\"build/key_name\")}"
    key_name = "foo"

    security_groups = "bar"

    user_data = ""

    asg_name = "test-asg"
    asg_max_size = 2
    asg_min_size = 1
    asg_desired_capacity = 1
    health_check_grace_period = 301
    default_cooldown = 301
    health_check_type = "ELB"
    load_balancer_name = "baz"

    availability_zones = "us-west-2a,us-west-2b,us-west-2c"
    subnet_ids = "quux"

    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    aws_region = "${var.aws_region}"
}
