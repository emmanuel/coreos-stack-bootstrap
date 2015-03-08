#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
STACK_NAME="Innovation-Platform-Visible-DNS-GTIN"
VISIBLE_ELB_HOSTED_ZONE_NAME=$(cat visible_elb_hosted_zone_name)
VISIBLE_ELB_HOSTED_ZONE_NAME_ID=$(cat visible_elb_hosted_zone_name_id)

aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$SCRIPT_PATH/gtin.json \
  --tags \
    Key=Team,Value=InnovationPlatform \
    Key=CostCenter,Value=45219 \
  --parameters \
    "ParameterKey=zoneDNSRoot,ParameterValue=cloud.nlab.io,UsePreviousValue=false" \
    "ParameterKey=visibleELBHostedZoneName,ParameterValue=${VISIBLE_ELB_HOSTED_ZONE_NAME},UsePreviousValue=false" \
    "ParameterKey=visibleELBHostedZoneNameID,ParameterValue=${VISIBLE_ELB_HOSTED_ZONE_NAME_ID},UsePreviousValue=false"
