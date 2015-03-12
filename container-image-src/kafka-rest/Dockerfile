FROM nordstrom/confluent-platform
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

RUN apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
     confluent-kafka-rest=1.0-1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD conf/kafka-rest.properties /etc/kafka-rest/kafka-rest.properties

ADD bin/start-kafka-rest.sh /bin/

EXPOSE 8082

CMD ["start-kafka-rest.sh"]
