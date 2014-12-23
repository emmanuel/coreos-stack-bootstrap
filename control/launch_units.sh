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
cd $SCRIPT_PATH/.

echo "Submitting units"
echo "================"
fleetctl submit units/logspout.service
fleetctl submit units/registrator.service
fleetctl submit units/skydns.service
fleetctl submit units/influxdb{,.elb,.presence,.create_db}@.service
fleetctl submit units/cadvisor.service
fleetctl submit units/sysinfo_influxdb.service
fleetctl submit units/zookeeper{,.volumes,.presence}@.service
fleetctl submit units/kafka{,.volumes,.presence,.create_topics}@.service
fleetctl submit units/syslog_gollector.service
fleetctl submit units/elasticsearch{,.volumes,.presence}@.service
fleetctl submit units/logstash{,.presence}@.service

echo "Starting services"
echo "================="
fleetctl start logspout
fleetctl start registrator
fleetctl start skydns
fleetctl start influxdb{,.elb,.presence}@1
fleetctl start influxdb.create_db@1
fleetctl start cadvisor
fleetctl start sysinfo_influxdb
fleetctl start zookeeper{,.volumes,.presence}@{1..3}
fleetctl start kafka{,.volumes,.presence}@{1..3}
fleetctl start units/kafka.create_topics@1
fleetctl start syslog_gollector
fleetctl start elasticsearch{,.volumes,.presence}@{1..2}
fleetctl start logstash{,.presence}@{1..2}
