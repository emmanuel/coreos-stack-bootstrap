#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# service instances
fleetctl destroy logstash.presence@1
fleetctl destroy logstash.presence@2
# fleetctl destroy logstash.presence@3
fleetctl destroy logstash@1
fleetctl destroy logstash@2
# fleetctl destroy logstash@3

# unit templates
fleetctl destroy logstash@.service
fleetctl destroy logstash.presence@.service
