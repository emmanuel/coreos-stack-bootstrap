#!/bin/bash

INFLUXDB_USER=root
INFLUXDB_PASS_ORIGINAL=root
INFLUXDB_PASS=something_good
INFLUXDB_SYSINFO_DB_NAME=sysinfo
INFLUXDB_DB_CONFIG_URL="http://localhost:8086/cluster/database_configs/mydb?u=${INFLUXDB_USER}&p=${INFLUXDB_PASS}"

/usr/bin/printf "Setting InfluxDB root password\n"
/usr/bin/curl -X POST 'http://localhost:8086/cluster_admins/root?u=root&p=${INFLUXDB_PASS_ORIGINAL}' -d '{"password": "${INFLUXDB_PASS}"}'

/usr/bin/printf "Creating InfluxDB database 'cadvisor'\n"
/usr/bin/curl -s -X POST http://localhost:8086/db?u=${INFLUXDB_USER}&p=${INFLUXDB_PASS} -d '{"name": "cadvisor"}'


/usr/bin/printf "Creating InfluxDB database 'sysinfo'\n"
/usr/bin/curl -s -X POST http://localhost:8086/db?u=${INFLUXDB_USER}&p=${INFLUXDB_PASS} -d '{"name": "sysinfo"}'

/usr/bin/printf "Creating InfluxDB database 'grafana'\n"
/usr/bin/curl -s -X POST "http://localhost:8086/db?u=${INFLUXDB_USER}&p=${INFLUXDB_PASS}" -d '{"name": "grafana"}'
