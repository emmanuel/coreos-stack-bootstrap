#!/bin/bash

# Thanks StackOverflow! http://stackoverflow.com/a/4774063
SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )

NAME=${1:-"CoreOS-grow-$RANDOM"}
DISCOVERY_URL=${DISCOVERY_URL:-`curl -s https://discovery.etcd.io/new`}
INSTANCE_TYPE=${INSTANCE_TYPE:-m3.large}
CLUSTER_SIZE=${4:-3}
KEY_PAIR=${5:-coreos-beta}
SECURITY_GROUP=${SECURITY_GROUP}

echo "Creating CloudFormation Stack with these parameters:"
echo "Name: $NAME"
echo "Discovery URL: $DISCOVERY_URL"
echo "Instance Type x Cluster Size: $INSTANCE_TYPE x $CLUSTER_SIZE"
echo "EC2 Key Pair: $KEY_PAIR"
echo "EC2 Security Group: $SECURITY_GROUP"

aws cloudformation create-stack \
  --stack-name $NAME \
  --template-body file://$SCRIPT_PATH/cloudformation-template-grow.json \
  --parameters \
    "ParameterKey=InstanceType,ParameterValue=$INSTANCE_TYPE,UsePreviousValue=false" \
    "ParameterKey=ClusterSize,ParameterValue=$CLUSTER_SIZE,UsePreviousValue=false" \
    "ParameterKey=DiscoveryURL,ParameterValue=$DISCOVERY_URL,UsePreviousValue=false" \
    "ParameterKey=AdvertisedIPAddress,ParameterValue=private,UsePreviousValue=false" \
    "ParameterKey=AllowSSHFrom,ParameterValue=0.0.0.0/0,UsePreviousValue=false" \
    "ParameterKey=KeyPair,ParameterValue=$KEY_PAIR,UsePreviousValue=false" \
    "ParameterKey=SecurityGroup,ParameterValue=$SECURITY_GROUP,UsePreviousValue=false"
