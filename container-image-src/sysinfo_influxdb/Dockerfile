FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/sysinfo_influxdb /usr/bin/sysinfo_influxdb

ENTRYPOINT ["/usr/bin/sysinfo_influxdb", "-D"]
