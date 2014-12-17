#!/bin/bash

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH

# service templates
fleetctl submit kafka.data@.service
fleetctl submit kafka.conf@.service
fleetctl submit kafka@.service
fleetctl submit kafka.create_topics@.service
fleetctl submit kafka.presence@.service
# service instances
fleetctl start kafka.data@1
fleetctl start kafka.data@2
fleetctl start kafka.data@3
fleetctl start kafka.conf@1
fleetctl start kafka.conf@2
fleetctl start kafka.conf@3
fleetctl start kafka@1
fleetctl start kafka@2
fleetctl start kafka@3
fleetctl start kafka.presence@1
fleetctl start kafka.presence@2
fleetctl start kafka.presence@3
fleetctl start kafka.create_topics@1.service
