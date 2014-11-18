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

fleetctl start logspout/logspout.service
fleetctl start skydns/skydns.service
influxdb/launch_units.sh
fleetctl start cadvisor/cadvisor.service
fleetctl start sysinfo_influxdb/sysinfo_influxdb.service
zookeeper/launch_units.sh
kafka/launch_units.sh
fleetctl start syslog-gollector/syslog-gollector.service
elasticsearch/launch_units.sh
logstash/launch_units.sh
