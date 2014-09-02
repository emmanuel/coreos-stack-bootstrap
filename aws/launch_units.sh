#!/bin/bash
cd $(dirname $0)/..

if [ -z "$FLEETCTL_TUNNEL" ]; then
    echo
    echo "You must set FLEETCTL_TUNNEL (a resolvable address to one of your CoreOS instances)"
    echo "e.g.:"
    echo "export FLEETCTL_TUNNEL=1.2.3.4"
    echo
    exit 1
fi

#fleetctl start graphite/graphite-carbon@1.service
#fleetctl start graphite/graphite-carbon.presence@1.service

fleetctl start influxdb/influxdb@1.service
fleetctl start influxdb/influxdb.presence@1.service
#fleetctl start influxdb/influxdb@2.service
#fleetctl start influxdb/influxdb.presence@2.service
#fleetctl start influxdb/influxdb@3.service
#fleetctl start influxdb/influxdb.presence@3.service
