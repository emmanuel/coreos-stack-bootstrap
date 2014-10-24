FROM nordstrom/java-7
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

# ENV ZOOKEEPER_VERSION 3.4.6
# ADD dist/zookeeper-$ZOOKEEPER_VERSION.tar.gz /opt/
# RUN mv /opt/zookeeper-$ZOOKEEPER_VERSION /opt/zookeeper
# ADD ./conf/zoo.cfg /opt/zookeeper/conf/zoo.cfg
# WORKDIR /opt/zookeeper

# CMD ["/opt/zookeeper/bin/zkServer.sh", "start-foreground"]

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-suggests --no-install-recommends zookeeper

ADD ./conf /etc/zookeeper/conf
# ADD ./conf/configuration.xsl /etc/zookeeper/conf/
# ADD ./conf/environment /etc/zookeeper/conf/
# ADD ./conf/log4j.properties /etc/zookeeper/conf/
# ADD ./conf/zoo.cfg /etc/zookeeper/conf/
ADD ./start.sh /

# Zookeeper client port
EXPOSE 2181
# Zookeeper peer port
EXPOSE 2888
# Zookeeper leader (election) port
EXPOSE 3888

# CMD ["/usr/share/zookeeper/bin/zkServer.sh", "start-foreground"]
CMD ["/start.sh"]
