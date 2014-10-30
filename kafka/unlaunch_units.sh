#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# service instances
fleetctl destroy kafka@1
fleetctl destroy kafka@2
fleetctl destroy kafka@3
fleetctl destroy kafka.presence@1
fleetctl destroy kafka.presence@2
fleetctl destroy kafka.presence@3
# service templates
fleetctl destroy kafka@.service
fleetctl destroy kafka.presence@.service
