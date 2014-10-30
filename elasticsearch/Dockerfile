FROM nordstrom/java-7
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

# RUN true \
#     && apt-get update -q -y \
#     && apt-get install -q -y --no-install-recommends --no-install-suggests \
#         elasticsearch \
#     && apt-get clean -q -y

# RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
# RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
# RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886

# TODO: figure out the HTTPS URL for the S3 bucket that backs packages.elasticsearch.org
RUN true \
    && apt-get install -q -y --no-install-suggests --no-install-recommends \
        wget \
    && wget -qO - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | apt-key add - \
    && echo "deb http://packages.elasticsearch.org/elasticsearch/1.3/debian stable main" | tee -a /etc/apt/sources.list.d/elasticsearch.list \
    && apt-get update -q -y \
    && apt-get install -q -y --no-install-suggests --no-install-recommends \
        elasticsearch \
    && apt-get clean

RUN /usr/share/elasticsearch/bin/plugin --verbose \
  --install zookeeper \
  --url https://github.com/grmblfrz/elasticsearch-zookeeper/releases/download/v1.3.1/elasticsearch-zookeeper-1.3.1.zip
# ADD dist/elasticsearch-zookeeper-1.3.2_1.zip /tmp/es-zookeeper/elasticsearch-zookeeper-1.3.2_1.zip
# RUN /usr/share/elasticsearch/bin/plugin --verbose \
#   --install fabric8io/elasticsearch-zookeeper \
#   --url file:///tmp/es-zookeeper/elasticsearch-zookeeper-1.3.2_1.zip

# ENV ES_RELEASE 1.3.2
# ADD dist/elasticsearch-$ES_RELEASE.tar.gz /opt/local/
# # RUN mv /opt/local/elasticsearch-$ES_RELEASE /opt/local/elasticsearch
# ADD conf /opt/local/elasticsearch-$ES_RELEASE/conf/
# ADD ./bin/start-elasticsearch.sh /usr/local/bin/start-elasticsearch.sh

# ElasticSearch client port
EXPOSE 9200
# ElasticSearch peer port
EXPOSE 9300

ENV PATH /bin:/usr/bin:/sbin:/usr/sbin
ENV LOG_DIR /var/log/elasticsearch
ENV DATA_DIR /var/lib/elasticsearch
ENV WORK_DIR /tmp/elasticsearch
ENV CONF_DIR /etc/elasticsearch
ENV CONF_FILE $CONF_DIR/elasticsearch.yml
ENV ES_HOME /usr/share/elasticsearch

ENV ES_USER elasticsearch
ENV ES_GROUP elasticsearch

ADD conf /etc/elasticsearch/
ADD ./bin/start-elasticsearch.sh /usr/local/bin/start-elasticsearch.sh

RUN mkdir -p "$LOG_DIR" "$DATA_DIR" "$WORK_DIR" && \
    chown "$ES_USER":"$ES_GROUP" "$LOG_DIR" "$DATA_DIR" "$WORK_DIR" && \
    chown -R "$ES_USER":"$ES_GROUP" "$CONF_DIR"

# ENV MAX_OPEN_FILES 65535
# ENV MAX_MAP_COUNT 262144

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/

# USER elasticsearch:elasticsearch

CMD ["/usr/local/bin/start-elasticsearch.sh"]
