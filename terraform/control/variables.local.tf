variable "aws_instance_type_control" {
  default = "m3.large"
}

variable "aws_sns_topic_contol_autoscaling_events_arn" {
  default = "arn:aws:sns:us-west-2:731703850786:control-autoscaling-events"
}
