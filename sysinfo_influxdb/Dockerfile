FROM nordstrom/baseimage-ubuntu-core-1404:latest
MAINTAINER Paul Payne "paul@payne.io"

ADD dist/sysinfo_influxdb /bin/sysinfo_influxdb

CMD ["/bin/sysinfo_influxdb", "-h", "influxdb-1:8086", "-u", "root", "-p", "root", "-D"]
