#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# zookeeper templates
# fleetctl submit zookeeper.data@.service
fleetctl submit zookeeper@.service
fleetctl submit zookeeper.presence@.service
# zookeeper service instances
# fleetctl start zookeeper.data@1
# fleetctl start zookeeper.data@2
# fleetctl start zookeeper.data@3
fleetctl start zookeeper@1
fleetctl start zookeeper@2
fleetctl start zookeeper@3
fleetctl start zookeeper.presence@1
fleetctl start zookeeper.presence@2
fleetctl start zookeeper.presence@3
