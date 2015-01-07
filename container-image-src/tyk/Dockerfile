FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez <emmanuel.gomez@nordstrom.com>

ADD dist/tyk.linux.amd64_1.3-1_all.deb /tmp/
RUN dpkg -i /tmp/tyk.linux.amd64_1.3-1_all.deb

ADD conf/ /etc/tyk/
