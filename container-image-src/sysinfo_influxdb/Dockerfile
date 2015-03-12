FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

ADD dist/sysinfo_influxdb-0.5.3 /bin/sysinfo_influxdb

ENTRYPOINT ["/bin/sysinfo_influxdb", "-D"]
