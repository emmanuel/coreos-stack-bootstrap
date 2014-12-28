FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez <emmanuel.gomez@nordstrom.com>

RUN apt-get update -qy \
 && apt-get install -qy --no-install-recommends --no-install-suggests \
     curl dnsutils \
 && apt-get clean -qy
