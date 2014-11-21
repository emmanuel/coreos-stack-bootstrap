#!/bin/bash

# Thanks StackOverflow! http://stackoverflow.com/a/4774063
SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )

LOAD_BALANCER_NAME=${LOAD_BALANCER_NAME:-"elb-$RANDOM"}
LOAD_BALANCER_PROTOCOL=${LOAD_BALANCER_PROTOCOL:-HTTP}
LOAD_BALANCER_PORT=${LOAD_BALANCER_PORT:-80}
INSTANCE_PROTOCOL=${INSTANCE_PROTOCOL:-HTTP}
INSTANCE_PORT=${INSTANCE_PORT:-80}
AVAILABILITY_ZONES=${AVAILABILITY_ZONES:-us-west-2a us-west-2b us-west-2c}

echo "Creating ELB load balancer with these parameters:"
echo "Name: $LOAD_BALANCER_NAME"
echo "Load balancer protocol: $LOAD_BALANCER_PROTOCOL"
echo "Load balancer port: $LOAD_BALANCER_PORT"
echo "Instance protocol: $INSTANCE_PROTOCOL"
echo "Instance port: $INSTANCE_PORT"
echo "Availability zones: $AVAILABILITY_ZONES"

aws elb create-load-balancer \
  --load-balancer-name $LOAD_BALANCER_NAME \
  --listeners \
    "Protocol=$LOAD_BALANCER_PROTOCOL,LoadBalancerPort=$LOAD_BALANCER_PORT,InstanceProtocol=$INSTANCE_PROTOCOL,InstancePort=$INSTANCE_PORT" \
  --availability-zones $AVAILABILITY_ZONES
