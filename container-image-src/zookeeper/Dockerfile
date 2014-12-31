FROM nordstrom/java-7:0.0.4
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

# RUN true \
#     && apt-get update -q -y \
#     && apt-get install -q -y --no-install-recommends --no-install-suggests \
#         zookeeper \
#     && apt-get clean -q -y

ENV ZK_RELEASE 3.4.6
ADD dist/zookeeper-$ZK_RELEASE.tar.gz /opt/local/
RUN ln -s /opt/local/zookeeper-$ZK_RELEASE/ /opt/zookeeper/
ADD conf /opt/zookeeper/conf/
ADD bin/start-zookeeper.sh /bin/start-zookeeper.sh

# Zookeeper client port
EXPOSE 2181
# Zookeeper peer port
EXPOSE 2888
# Zookeeper leader (election) port
EXPOSE 3888

CMD ["/bin/start-zookeeper.sh"]
