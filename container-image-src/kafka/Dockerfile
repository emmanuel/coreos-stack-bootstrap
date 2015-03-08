FROM nordstrom/confluent-platform
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

RUN apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
     confluent-kafka-2.10.4 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD conf/server.properties /etc/kafka/server.properties

ADD bin/start-kafka.sh /bin/

CMD ["start-kafka.sh"]
