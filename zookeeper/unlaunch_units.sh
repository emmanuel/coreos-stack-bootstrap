#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# zookeeper service instances
fleetctl destroy zookeeper.data@1
fleetctl destroy zookeeper.data@2
fleetctl destroy zookeeper.data@3
fleetctl destroy zookeeper@1
fleetctl destroy zookeeper@2
fleetctl destroy zookeeper@3
fleetctl destroy zookeeper.presence@1
fleetctl destroy zookeeper.presence@2
fleetctl destroy zookeeper.presence@3

fleetctl destroy zookeeper.data@.service
fleetctl destroy zookeeper@.service
fleetctl destroy zookeeper.presence@.service