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

echo "Stopping services"
echo "================="
fleetctl stop vulcand{,.elb,.presence}
fleetctl stop logstash{,.presence}@{1..2}
fleetctl stop elasticsearch{,.presence}@{1..2}
fleetctl stop syslog_gollector
fleetctl stop kafka{,.presence}@{1..3}
fleetctl stop zookeeper{,.presence}@{1..3}
fleetctl stop sysinfo_influxdb
fleetctl stop cadvisor
fleetctl stop influxdb.create_db
fleetctl stop influxdb{,.elb,.presence}@1
fleetctl stop skydns
fleetctl stop registrator
fleetctl stop logspout
