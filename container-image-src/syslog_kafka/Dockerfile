FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

ADD dist/syslog_kafka-c5dc8bb05f5a /bin/syslog_kafka

# syslog
EXPOSE 514
EXPOSE 514/udp

ENTRYPOINT ["/bin/syslog_kafka"]
