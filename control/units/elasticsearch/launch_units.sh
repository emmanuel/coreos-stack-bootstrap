#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# elasticsearch templates
fleetctl submit elasticsearch.data@.service
fleetctl submit elasticsearch@.service
fleetctl submit elasticsearch.presence@.service
# elasticsearch service instances
fleetctl start elasticsearch.data@1
fleetctl start elasticsearch.data@2
# fleetctl start elasticsearch.data@3
fleetctl start elasticsearch@1
fleetctl start elasticsearch@2
# fleetctl start elasticsearch@3
fleetctl start elasticsearch.presence@1
fleetctl start elasticsearch.presence@2
# fleetctl start elasticsearch.presence@3
