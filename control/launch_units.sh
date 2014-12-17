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

fleetctl start units/logspout/logspout.service
fleetctl start units/registrator/registrator.service
fleetctl start units/skydns/skydns.service
units/influxdb/launch_units.sh
fleetctl start units/cadvisor/cadvisor.service
fleetctl start units/sysinfo_influxdb/sysinfo_influxdb.service
units/zookeeper/launch_units.sh
units/kafka/launch_units.sh
fleetctl start units/syslog-gollector/syslog_gollector.service
units/elasticsearch/launch_units.sh
units/logstash/launch_units.sh
