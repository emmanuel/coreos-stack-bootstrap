FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/skydns-2.0.1d /usr/local/bin/skydns

EXPOSE 53/udp

ENTRYPOINT ["/usr/local/bin/skydns"]
