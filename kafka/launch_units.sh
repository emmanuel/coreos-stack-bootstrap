#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# service templates
fleetctl submit kafka@.service
fleetctl submit kafka.presence@.service
# service instances
fleetctl start kafka@1
fleetctl start kafka@2
fleetctl start kafka@3
fleetctl start kafka.presence@1
fleetctl start kafka.presence@2
fleetctl start kafka.presence@3
