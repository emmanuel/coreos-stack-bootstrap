FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/syslog-gollector /bin/syslog-gollector

# syslog
EXPOSE 514
EXPOSE 514/udp
# admin interface
EXPOSE 8080

ENTRYPOINT ["/bin/syslog-gollector"]
CMD []
