FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD conf/logstash-forwarder-conf.json /etc/
ADD dist/logstash-forwarder /bin/

ENTRYPOINT ["/bin/logstash-forwarder", "-config", "/etc/logstash-forwarder-conf.json"]
