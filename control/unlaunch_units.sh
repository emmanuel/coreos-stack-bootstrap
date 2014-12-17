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

units/logstash/unlaunch_units.sh
fleetctl destroy units/cadvisor/cadvisor.service
fleetctl destroy units/sysinfo_influxdb/sysinfo_influxdb.service
units/influxdb/unlaunch_units.sh
fleetctl destroy units/syslog-gollector/syslog_gollector.service
units/elasticsearch/unlaunch_units.sh
units/kafka/unlaunch_units.sh
units/zookeeper/unlaunch_units.sh
fleetctl destroy units/skydns/skydns.service
fleetctl destroy units/registrator/registrator.service
fleetctl destroy units/logspout/logspout.service
