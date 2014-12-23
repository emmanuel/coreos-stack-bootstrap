FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/skydns-2.0.1d /bin/skydns

EXPOSE 53/udp

ENTRYPOINT ["/bin/skydns"]
