FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/sysinfo_influxdb-0.5.3 /bin/sysinfo_influxdb

ENTRYPOINT ["/bin/sysinfo_influxdb", "-D"]
