FROM nordstrom/java-7:0.0.4
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ENV LOGSTASH_RELEASE 1.4.2
ADD dist/logstash-$LOGSTASH_RELEASE.tar.gz /opt/
# ADD dist/logstash-contrib-$LOGSTASH_RELEASE.tar.gz /opt/
# ADD dist/logstash-contrib-$LOGSTASH_RELEASE.tar.gz /opt/
RUN ln -s /opt/logstash-$LOGSTASH_RELEASE /opt/logstash
# RUN mkdir /opt/logstash \
#  && cp -al /opt/logstash-$LOGSTASH_RELEASE/* /opt/logstash-contrib-$LOGSTASH_RELEASE/* /opt/logstash \
#  && rm -rf /opt/logstash-$LOGSTASH_RELEASE /opt/logstash-contrib-$LOGSTASH_RELEASE
# https://github.com/elasticsearch/logstash-forwarder#user-content-generating-an-ssl-certificate
# ADD conf/logstash-forwarder.crt /etc/pki/tls/certs/
# ADD conf/logstash-forwarder.key /etc/pki/tls/private/
ADD conf/logstash.conf /opt/logstash/conf/
ADD pki/logstash-forwarder.crt /etc/pki/tls/certs/logstash.crt
ADD pki/logstash-forwarder.key /etc/pki/tls/private/logstash.key

CMD ["/opt/logstash/bin/logstash", "-f", "/opt/logstash/conf/logstash.conf"]
