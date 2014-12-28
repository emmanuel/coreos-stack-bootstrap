FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

RUN apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
     nmap \
 && apt-get clean -qy

ENTRYPOINT ["/usr/bin/ncat"]
