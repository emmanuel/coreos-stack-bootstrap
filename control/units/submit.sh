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

echo "Submitting units"
echo "================"
fleetctl submit logspout.service
fleetctl submit registrator.service
fleetctl submit skydns.service
fleetctl submit influxdb{,.elb,.presence}@.service
fleetctl submit influxdb.create_db.service
fleetctl submit cadvisor.service
fleetctl submit sysinfo_influxdb.service
fleetctl submit zookeeper{,.volumes,.presence}@.service
fleetctl submit kafka{,.volumes,.presence,.create_topics}@.service
fleetctl submit syslog_gollector.service
fleetctl submit elasticsearch{,.volumes,.presence}@.service
fleetctl submit logstash{,.presence}@.service
