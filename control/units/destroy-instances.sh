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
cd $SCRIPT_PATH

echo "Destroying services"
echo "==================="
fleetctl destroy vulcand{,.elb}
fleetctl destroy logstash@{1..2}
fleetctl destroy elasticsearch@{1..2}
fleetctl destroy syslog_gollector
fleetctl destroy kafka@{1..3}
fleetctl destroy zookeeper{,.presence}@{1..3}
fleetctl destroy sysinfo_influxdb
fleetctl destroy cadvisor
# fleetctl destroy influxdb.create_db@1
fleetctl destroy influxdb{,.elb}@1
fleetctl destroy skydns
fleetctl destroy registrator
fleetctl destroy logspout
