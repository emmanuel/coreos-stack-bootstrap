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
cd $SCRIPT_PATH/units

echo "Destroying services"
echo "==================="
fleetctl destroy docker-registry.vulcand_frontend
fleetctl destroy docker-registry{,.vulcand}@{1..2}
fleetctl destroy logstash@1
fleetctl destroy elasticsearch@{1..3}
fleetctl destroy syslog_kafka
fleetctl destroy kafka@{1..5}
fleetctl destroy zookeeper@{1..5}
fleetctl destroy sysinfo_influxdb
fleetctl destroy cadvisor
fleetctl destroy influxdb.{vulcand_frontend,create_db}
fleetctl destroy influxdb{.vulcand,}@1
fleetctl destroy vulcand
fleetctl destroy redis@1
fleetctl destroy redis-lru@1
fleetctl destroy skydns{,-registrator}
fleetctl destroy logrotate
fleetctl destroy consul{,-announce,-registrator}
fleetctl destroy logspout
fleetctl destroy aws_credentials
