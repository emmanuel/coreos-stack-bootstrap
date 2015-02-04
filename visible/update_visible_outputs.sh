#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH/control

rm ../visible_values.tfvars

echo "aws_elb_name_etcd_visible                 = \"visible-etcd-internal\""    >> ../visible_values.tfvars
echo "aws_security_group_elb_etcd_visible_id    = \"sg-51782b34\""              >> ../visible_values.tfvars
echo "aws_elb_name_vulcand_visible              = \"visible-vulcand-external\"" >> ../visible_values.tfvars
echo "aws_security_group_elb_vulcand_visible_id = \"sg-01782b64\""              >> ../visible_values.tfvars
echo "aws_elb_name_gtin_visible                 = \"visible-gtin-external\""    >> ../visible_values.tfvars
echo "aws_security_group_elb_gtin_visible_id    = \"sg-064c1d63\""              >> ../visible_values.tfvars
