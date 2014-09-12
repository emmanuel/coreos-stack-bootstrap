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
fleetctl submit influxdb/influxdb@.service
fleetctl submit influxdb/influxdb.presence@.service
fleetctl submit influxdb/influxdb.elb@.service
fleetctl submit influxdb/influxdb.db_create@.service

fleetctl start influxdb/influxdb@1.service
fleetctl start influxdb/influxdb.presence@1.service
fleetctl start influxdb/influxdb.elb@1.service
fleetctl start influxdb/influxdb.db_create@1.service

fleetctl start cadvisor/cadvisor.service
fleetctl start sysinfo_influxdb/sysinfo_influxdb.service
fleetctl start grafana/grafana.service