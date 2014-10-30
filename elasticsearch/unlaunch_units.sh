#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# service instances
fleetctl destroy elasticsearch.data@1
fleetctl destroy elasticsearch.data@2
# fleetctl destroy elasticsearch.data@3
fleetctl destroy elasticsearch@1
fleetctl destroy elasticsearch@2
# fleetctl destroy elasticsearch@3
fleetctl destroy elasticsearch.presence@1
fleetctl destroy elasticsearch.presence@2
# fleetctl destroy elasticsearch.presence@3
# service templates
fleetctl destroy elasticsearch.presence@.service
fleetctl destroy elasticsearch@.service
fleetctl destroy elasticsearch.data@.service
