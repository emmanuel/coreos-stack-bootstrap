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

fleetctl start units/logspout.service
fleetctl start units/registrator.service
fleetctl start units/skydns.service

fleetctl submit units/influxdb{.elb,.presence,.create_db,}@.service
fleetctl start influxdb{.elb,.presence,}@1
fleetctl start units/influxdb.create_db@1.service

fleetctl start units/cadvisor.service
fleetctl start units/sysinfo_influxdb.service

fleetctl submit units/zookeeper{.data,.presence,}@.service
fleetctl start units/zookeeper{.data,.presence,}@{1..3}

fleetctl submit units/kafka{.conf,.data,.presence,.create_topics,}@.service
fleetctl start units/kafka{.conf,.data,.presence,}@{1..3}
fleetctl start units/kafka.create_topics@1

fleetctl start units/syslog_gollector.service

fleetctl submit units/elasticsearch{.data,.presence,}@.service
fleetctl start units/elasticsearch{.data,.presence,}@{1..2}

fleetctl submit units/logstash{.presence,}@.service
fleetctl start units/logstash{.presence,}@{1..2}
