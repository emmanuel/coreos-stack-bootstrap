FROM nordstrom/confluent-platform
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

RUN apt-get update -qy \
 && apt-get install -qy --no-install-suggests --no-install-recommends \
     confluent-schema-registry=1.0-1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD conf/schema-registry.properties /etc/schema-registry/schema-registry.properties

EXPOSE 8081

CMD ["schema-registry-start", "/etc/schema-registry/schema-registry.properties"]
