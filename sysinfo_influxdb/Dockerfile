FROM nordstrom/baseimage-ubuntu-core-1404:latest
MAINTAINER Paul Payne "paul@payne.io"

ADD dist/sysinfo_influxdb /bin/sysinfo_influxdb

ENTRYPOINT ["/bin/sysinfo_influxdb", "-D"]

CMD ["-D"]
