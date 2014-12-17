FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

# also consider rsyslog-mmjsonparse package/module to parse incoming messages as CEE JSON
RUN echo "deb http://ppa.launchpad.net/adiscon/v8-stable/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/adiscon-rsyslog-v8-stable.list \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0F6DD8135234BF2B \
 && apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
     rsyslog \
     rsyslog-elasticsearch \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ADD conf/rsyslog.conf /etc/rsyslog.conf
ADD conf/50-default.conf /etc/rsyslog.d/50-default.conf
ADD conf/rsyslog-journal-syslog.conf /etc/rsyslog.d/51-journal-syslog.conf

VOLUME /rsyslog/data/
