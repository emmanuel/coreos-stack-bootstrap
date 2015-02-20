FROM nordstrom/java-7:u75
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ENV ZK_RELEASE 3.4.6
ADD dist/zookeeper-$ZK_RELEASE.tar.gz /opt/
RUN ln -s /opt/zookeeper-$ZK_RELEASE /opt/zookeeper
ADD ./conf /opt/zookeeper/conf/

# Zookeeper client port
EXPOSE 2181
# Zookeeper peer port
EXPOSE 2888
# Zookeeper leader (election) port
EXPOSE 3888

CMD ["/opt/zookeeper/bin/zkServer.sh", "start-foreground"]
