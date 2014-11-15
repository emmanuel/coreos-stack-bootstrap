FROM nordstrom/ubuntu-min:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/skydns /usr/local/bin/skydns

EXPOSE 53/udp

ENTRYPOINT ["/usr/local/bin/skydns"]
