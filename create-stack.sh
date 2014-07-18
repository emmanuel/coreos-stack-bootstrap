#!/bin/bash

STACK_NAME=${1:-"CoreOS-test-$RANDOM"}
STACK_DISCOVERY_URL=${2:-`curl -s https://discovery.etcd.io/new`}
STACK_INSTANCE_TYPE=${3:-m3.medium}
STACK_CLUSTER_SIZE=${4:-3}

echo $STACK_NAME
echo $STACK_DISCOVERY_URL
echo $STACK_INSTANCE_TYPE x $STACK_CLUSTER_SIZE

aws cloudformation create-stack \
--stack-name $STACK_NAME \
--template-body file://$PWD/cloudformation-template.json \
--parameters "ParameterKey=InstanceType,ParameterValue=$STACK_INSTANCE_TYPE,UsePreviousValue=false" \
"ParameterKey=ClusterSize,ParameterValue=$STACK_CLUSTER_SIZE,UsePreviousValue=false" \
"ParameterKey=DiscoveryURL,ParameterValue=$STACK_DISCOVERY_URL,UsePreviousValue=false" \
"ParameterKey=AdvertisedIPAddress,ParameterValue=private,UsePreviousValue=false" \
"ParameterKey=AllowSSHFrom,ParameterValue=0.0.0.0/0,UsePreviousValue=false" \
"ParameterKey=KeyPair,ParameterValue=coreos-beta,UsePreviousValue=false"
