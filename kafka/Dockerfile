FROM nordstrom/java-7
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ENV KAFKA_SCALA_VERSION 2.9.2
ENV KAFKA_VERSION 0.8.1.1

ENV KAFKA_RELEASE $KAFKA_SCALA_VERSION-$KAFKA_VERSION
ENV KAFKA_HOME /opt/kafka_$KAFKA_RELEASE

ADD dist/kafka_$KAFKA_RELEASE.tgz /opt/
ADD conf/server.properties $KAFKA_HOME/config/server.properties
ADD bin/start.sh /bin/start.sh

CMD ["/bin/start.sh"]
