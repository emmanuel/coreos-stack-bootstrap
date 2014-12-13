FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/logstash-forwarder /bin/
ADD conf/pki/logstash-forwarder.crt /etc/pki/tls/certs/
ADD conf/pki/logstash-forwarder.key /etc/pki/tls/private/
ADD conf/logstash-forwarder-conf.json /etc/

ENTRYPOINT ["/bin/logstash-forwarder", "-config", "/etc/logstash-forwarder-conf.json"]
