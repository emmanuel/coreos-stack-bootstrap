#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
STACK_NAME="Innovation-Platform-Visible-IAM"

aws cloudformation update-stack \
  --stack-name $STACK_NAME \
  --template-body file://$SCRIPT_PATH/iam.json \
  --capabilities CAPABILITY_IAM \
  --no-use-previous-template \
  --parameters \
    "ParameterKey=readableS3BucketsGlob,UsePreviousValue=true" \
    "ParameterKey=dockerRegistryS3BucketName,UsePreviousValue=true" \
    "ParameterKey=registerableLoadBalancersPath,UsePreviousValue=true" \
    "ParameterKey=readableDynamoDBTablesPath,UsePreviousValue=true"
