FROM ubuntu-debootstrap:14.04.1
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update -qy \
 && apt-get upgrade -qy --no-install-recommends --no-install-suggests \
 && apt-get install -qy --no-install-recommends --no-install-suggests \
      apt-transport-https \
      ca-certificates \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
