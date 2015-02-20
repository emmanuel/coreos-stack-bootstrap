FROM nordstrom/java-7:u75
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ENV KAFKA_SCALA_VERSION 2.11
ENV KAFKA_VERSION 0.8.2-beta

ENV KAFKA_RELEASE $KAFKA_SCALA_VERSION-$KAFKA_VERSION
ENV KAFKA_HOME /opt/kafka_$KAFKA_RELEASE

ADD dist/kafka_$KAFKA_RELEASE.tgz /opt/
RUN ln -s /opt/kafka_$KAFKA_RELEASE /opt/kafka

ADD conf/server.properties $KAFKA_HOME/config/server.properties
ADD bin/start-kafka.sh /bin/

CMD ["/bin/start-kafka.sh"]
