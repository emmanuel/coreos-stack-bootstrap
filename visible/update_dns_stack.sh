#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
STACK_NAME="Innovation-Platform-Visible-DNS-ELB-S3"

aws cloudformation update-stack \
  --stack-name $STACK_NAME \
  --template-body file://$SCRIPT_PATH/dns.json \
  --no-use-previous-template \
  --parameters \
    "ParameterKey=zoneDNSRoot,UsePreviousValue=true" \
    "ParameterKey=keyName,UsePreviousValue=true" \
    "ParameterKey=sslCertificateIAMPath,UsePreviousValue=true" \
    "ParameterKey=dockerRegistryBucketName,UsePreviousValue=true"
