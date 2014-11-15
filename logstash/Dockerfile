FROM nordstrom/java-7
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

EXPOSE 5000

ENV LOGSTASH_RELEASE 1.4.2
ADD dist/logstash-$LOGSTASH_RELEASE.tar.gz /opt/
ADD bin/start-logstash.sh /bin/
# https://github.com/elasticsearch/logstash-forwarder#user-content-generating-an-ssl-certificate
ADD conf/logstash-forwarder.crt /etc/pki/tls/certs/
ADD conf/logstash-forwarder.key /etc/pki/tls/private/
# ADD dist/logstash-contrib-$LOGSTASH_RELEASE.tar.gz /opt/
ADD conf/logstash.conf /opt/logstash-$LOGSTASH_RELEASE/conf/

CMD ["/bin/start-logstash.sh"]
