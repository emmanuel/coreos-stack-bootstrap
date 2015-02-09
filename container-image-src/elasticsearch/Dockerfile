FROM nordstrom/java-7:0.0.5
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

ADD dist/GPG-KEY-elasticsearch /tmp/
# TODO: figure out the HTTPS URL for the S3 bucket that backs packages.elasticsearch.org
RUN /usr/bin/apt-key add /tmp/GPG-KEY-elasticsearch \
 && /bin/echo "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main" | \
    /usr/bin/tee -a /etc/apt/sources.list.d/elasticsearch.list

RUN /usr/bin/apt-get update -qy \
 && /usr/bin/apt-get install -qy --no-install-suggests --no-install-recommends \
     elasticsearch \
 && /usr/bin/apt-get clean

RUN /usr/share/elasticsearch/bin/plugin --verbose \
  --install zookeeper \
  --url https://github.com/grmblfrz/elasticsearch-zookeeper/releases/download/v1.4.2/elasticsearch-zookeeper-1.4.2.zip

# ElasticSearch client port
EXPOSE 9200
# ElasticSearch peer port
EXPOSE 9300

ENV PATH /bin:/usr/bin:/sbin:/usr/sbin
# used to configure elasticsearch
ENV LOG_DIR /var/log/elasticsearch
ENV DATA_DIR /var/lib/elasticsearch
ENV WORK_DIR /tmp/elasticsearch
ENV CONF_DIR /etc/elasticsearch
ENV CONF_FILE $CONF_DIR/elasticsearch.yml
ENV ES_HOME /usr/share/elasticsearch

ENV ES_USER elasticsearch
ENV ES_GROUP elasticsearch

ADD conf /etc/elasticsearch/
ADD bin/start-elasticsearch.sh /bin/start-elasticsearch.sh

RUN mkdir -p "$LOG_DIR" "$DATA_DIR" "$WORK_DIR" \
 && chown "$ES_USER":"$ES_GROUP" "$LOG_DIR" "$DATA_DIR" "$WORK_DIR" \
 && chown -R "$ES_USER":"$ES_GROUP" "$CONF_DIR"

# ENV MAX_OPEN_FILES 65535
# ENV MAX_MAP_COUNT 262144

# USER elasticsearch:elasticsearch

CMD ["/bin/start-elasticsearch.sh"]
