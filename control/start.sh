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

echo "Starting services"
echo "================="
fleetctl start logspout
fleetctl start logrotate
fleetctl start registrator
fleetctl start skydns
fleetctl start influxdb{,.volumes}@1
fleetctl start vulcand{,.elb}@1
sleep 30
fleetctl start influxdb.create_db
fleetctl start cadvisor
fleetctl start sysinfo_influxdb
fleetctl start zookeeper{,.placement}@{1..5}
sleep 60
fleetctl start kafka{,.volumes}@{1..5}
fleetctl start elasticsearch{,.volumes}@{1..3}
sleep 60
fleetctl start kafka.create_topics
fleetctl start logstash@1
fleetctl start syslog_gollector
