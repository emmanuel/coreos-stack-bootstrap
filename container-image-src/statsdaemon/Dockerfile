FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/statsdaemon-0.6-alpha /bin/statsdaemon

# statsd
EXPOSE 8125/udp

ENTRYPOINT ["/bin/statsdaemon"]
