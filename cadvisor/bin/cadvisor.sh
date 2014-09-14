#!/bin/bash

INFLUXDB_HOST_IP=$(host ${INFLUXDB_HOSTNAME} | grep 'has address' | cut -f4 -d' ')
INFLUXDB_HOST=${INFLUXDB_HOST_IP}:${INFLUXDB_PORT}

echo "Writing to InfluxDB at ${INFLUXDB_HOST} into database '${INFLUXDB_DATABASE_NAME}'"

/usr/bin/cadvisor \
  --logtostderr \
  --storage_driver=influxdb \
  --storage_driver_host=${INFLUXDB_HOST} \
  --storage_driver_db=${INFLUXDB_DATABASE_NAME} \
  --storage_driver_user=${INFLUXDB_DATABASE_USER} \
  --storage_driver_password=${INFLUXDB_DATABASE_PASS} \
  --housekeeping_interval=5s \
  --global_housekeeping_interval=10s
