FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

RUN apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
      python-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
