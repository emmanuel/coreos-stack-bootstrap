FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

ADD dist/skydns-2.0.1d /bin/skydns

EXPOSE 53/udp

ENTRYPOINT ["/bin/skydns"]
