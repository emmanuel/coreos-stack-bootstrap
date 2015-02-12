resource "aws_route53_record" "vulcand_visible_gtin" {
  zone_id = "${var.aws_route53_zone_id_cloud_nlab_io}"
  name = "gtin.api.cloud.nlab.io"
  type = "CNAME"
  ttl = "900"
  records = [ "${aws_elb.vulcand_visible.dns_name}" ]
}
