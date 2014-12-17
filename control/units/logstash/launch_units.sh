#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# unit templates
fleetctl submit logstash@.service
fleetctl submit logstash.presence@.service
# service instances
fleetctl start logstash@1
fleetctl start logstash@2
# fleetctl start logstash@3
fleetctl start logstash.presence@1
fleetctl start logstash.presence@2
# fleetctl start logstash.presence@3
