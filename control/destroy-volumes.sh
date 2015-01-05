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

echo "Destroying volumes"
echo "==================="
fleetctl destroy elasticsearch.volumes@{1..2}
fleetctl destroy kafka.volumes@{1..5}
fleetctl destroy zookeeper.placement@{1..5}
fleetctl destroy influxdb.volumes@1
