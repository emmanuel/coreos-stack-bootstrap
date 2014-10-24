FROM nordstrom/java-7
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-suggests --no-install-recommends zookeeper

ADD ./conf /etc/zookeeper/conf
ADD ./bin/start.sh /usr/local/bin/start-zookeeper.sh

# Zookeeper client port
EXPOSE 2181
# Zookeeper peer port
EXPOSE 2888
# Zookeeper leader (election) port
EXPOSE 3888

CMD ["/usr/local/bin/start-zookeeper.sh"]
