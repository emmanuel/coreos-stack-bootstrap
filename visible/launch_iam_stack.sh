#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
STACK_NAME="Innovation-Platform-Visible-IAM-Stack"

aws cloudformation create-stack \
  --stack-name $STACK_NAME \
  --template-body file://$SCRIPT_PATH/iam.json \
  --capabilities CAPABILITY_IAM \
  --tags \
    Key=Team,Value=InnovationPlatform \
    Key=CostCenter,Value=45219 \
  --parameters \
    "ParameterKey=readableS3BucketsGlob,ParameterValue=innovation-platform-*" \
    "ParameterKey=dockerRegistryS3BucketName,ParameterValue=internal-docker-registry" \
    "ParameterKey=registerableLoadBalancersPath,ParameterValue=loadbalancer/*" \
    "ParameterKey=readableDynamoDBTablesPath,ParameterValue=table/*"
