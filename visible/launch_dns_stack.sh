#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
STACK_NAME="Innovation-Platform-Visible-DNS-ELB-S3"

aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$SCRIPT_PATH/dns.json \
  --tags \
    Key=Team,Value=InnovationPlatform \
    Key=CostCenter,Value=45219 \
  --parameters \
    "ParameterKey=zoneDNSRoot,ParameterValue=cloud.nlab.io,UsePreviousValue=false" \
    "ParameterKey=keyName,ParameterValue=coreos-beta,UsePreviousValue=false" \
    "ParameterKey=sslCertificateIAMPath,ParameterValue=/tls/STAR.cloud.nlab.io,UsePreviousValue=false" \
    "ParameterKey=dockerRegistryBucketName,ParameterValue=docker-registry,UsePreviousValue=false"
