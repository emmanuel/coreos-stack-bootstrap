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

fleetctl destroy skydns/skydns.service
influxdb/unlaunch_units.sh
fleetctl destroy cadvisor/cadvisor.service
fleetctl destroy sysinfo_influxdb/sysinfo_influxdb.service
zookeeper/unlaunch_units.sh
kafka/unlaunch_units.sh
elasticsearch/unlaunch_units.sh
