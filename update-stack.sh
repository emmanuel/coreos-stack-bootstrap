#!/bin/bash

STACK_NAME=${1:-"CoreOS-test-$RANDOM"}
STACK_DISCOVERY_URL=${2:-`curl -s https://discovery.etcd.io/new`}
STACK_KEY_PAIR=${3:-coreos-beta}

echo "Updating CloudFormation Stack with these parameters:"
echo "Name: $STACK_NAME"
echo "Discovery URL: $STACK_DISCOVERY_URL"
echo "EC2 Key Pair: $STACK_KEY_PAIR"

aws cloudformation update-stack \
  --stack-name $STACK_NAME \
  --template-body file://$PWD/cloudformation-template.json \
  --parameters \
    "ParameterKey=DiscoveryURL,ParameterValue=$STACK_DISCOVERY_URL,UsePreviousValue=false" \
    "ParameterKey=KeyPair,ParameterValue=$STACK_KEY_PAIR,UsePreviousValue=false"
