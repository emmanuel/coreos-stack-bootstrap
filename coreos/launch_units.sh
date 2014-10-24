#!/bin/bash

if [ -z "$FLEETCTL_TUNNEL" ]; then
    echo
    echo "You must set FLEETCTL_TUNNEL (a resolvable address to one of your CoreOS instances)"
    echo "e.g.:"
    echo "export FLEETCTL_TUNNEL=1.2.3.4"
    echo
    exit 1
fi

SCRIPT_PATH=$( cd $(dirname $0) ; pwd -P )
cd $SCRIPT_PATH/..

# Global units
fleetctl start skydns/skydns.service
# Add the service templates to Fleet
# influxdb
fleetctl submit influxdb/influxdb@.service
fleetctl submit influxdb/influxdb.db_create@.service
fleetctl submit influxdb/influxdb.presence@.service
fleetctl submit influxdb/influxdb.elb@.service
# Start instantiated units from the templates (+ a number)
# influxdb
fleetctl start influxdb/influxdb@1.service
fleetctl start influxdb/influxdb.db_create@1.service
fleetctl start influxdb/influxdb.presence@1.service
fleetctl start influxdb/influxdb.elb@1.service
# Global units
fleetctl start cadvisor/cadvisor.service
fleetctl start sysinfo_influxdb/sysinfo_influxdb.service
# zookeeper templates
fleetctl submit zookeeper/zookeeper.data@.service
fleetctl submit zookeeper/zookeeper@.service
fleetctl submit zookeeper/zookeeper.presence@.service
# zookeeper service instances
fleetctl start zookeeper/zookeeper.data@1
fleetctl start zookeeper/zookeeper.data@2
fleetctl start zookeeper/zookeeper.data@3
fleetctl start zookeeper/zookeeper@1
fleetctl start zookeeper/zookeeper@2
fleetctl start zookeeper/zookeeper@3
fleetctl start zookeeper/zookeeper.presence@1
fleetctl start zookeeper/zookeeper.presence@2
fleetctl start zookeeper/zookeeper.presence@3
