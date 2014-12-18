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

fleetctl destroy units/logstash{.presence,}@{1..3}
fleetctl destroy units/logstash{.presence,}@.service

fleetctl destroy units/elasticsearch{.data,.presence,}@{1..3}
fleetctl destroy units/elasticsearch{.data,.presence,}@.service

fleetctl destroy units/syslog_gollector.service

fleetctl destroy units/kafka.create_topics@1
fleetctl destroy units/kafka{.conf,.data,.presence,}@{1..3}
fleetctl destroy units/kafka{.conf,.data,.presence,.create_topics,}@.service

fleetctl destroy units/zookeeper{.data,.presence,}@{1..3}
fleetctl destroy units/zookeeper{.data,.presence,}@.service

fleetctl destroy units/sysinfo_influxdb.service
fleetctl destroy units/cadvisor.service

fleetctl destroy units/influxdb.create_db@1.service
fleetctl destroy influxdb{.elb,.presence,}@1
fleetctl destroy units/influxdb{.elb,.presence,.create_db,}@.service

fleetctl destroy units/skydns.service
fleetctl destroy units/registrator.service
fleetctl destroy units/logspout.service
