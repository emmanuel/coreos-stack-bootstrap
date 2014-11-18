FROM nordstrom/java-7:0.0.4
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

# RUN true \
#     && apt-get update -q -y \
#     && apt-get install -q -y --no-install-recommends --no-install-suggests \
#         zookeeper \
#     && apt-get clean -q -y

ENV ZK_RELEASE 3.4.6
ADD dist/zookeeper-$ZK_RELEASE.tar.gz /opt/local/
# RUN mv /opt/local/zookeeper-$ZK_RELEASE /opt/local/zookeeper
ADD conf /opt/local/zookeeper-$ZK_RELEASE/conf/
ADD ./bin/start-zookeeper.sh /usr/local/bin/start-zookeeper.sh
RUN mkdir -p /var/lib/zookeeper

# Zookeeper client port
EXPOSE 2181
# Zookeeper peer port
EXPOSE 2888
# Zookeeper leader (election) port
EXPOSE 3888

CMD ["/usr/local/bin/start-zookeeper.sh"]
