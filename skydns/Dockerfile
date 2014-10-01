FROM progrium/busybox
MAINTAINER Emmanuel Gomez "emmanuel@gomez.io"

ADD dist/skydns /usr/bin/skydns

EXPOSE 53/udp

ENTRYPOINT ["/usr/bin/skydns"]
