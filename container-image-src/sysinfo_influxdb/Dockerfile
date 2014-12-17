FROM progrium/busybox
MAINTAINER Emmanuel Gomez "emmanuel@gomez.io"

ADD dist/sysinfo_influxdb /usr/bin/sysinfo_influxdb

ENTRYPOINT ["/usr/bin/sysinfo_influxdb", "-D"]
