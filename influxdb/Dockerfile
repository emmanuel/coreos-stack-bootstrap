FROM nordstrom/baseimage-ubuntu:14.04
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

# http://s3.amazonaws.com/influxdb/influxdb-0.8.3.amd64.tar.gz
# http://s3.amazonaws.com/influxdb/influxdb_0.8.6_amd64.deb
ADD dist/influxdb_0.8.6_amd64.deb /
# RUN mv /opt/influxdb-0.8.6.amd64 /opt/influxdb
RUN mkdir -p /opt/influxdb/shared/data && \
    dpkg -i /influxdb_0.8.6_amd64.deb && \
    rm -rf /opt/influxdb/shared/data && \
    chown -R daemon:daemon /opt/influxdb

ADD conf/config.toml /opt/influxdb/shared/config.toml

# USER daemon

# HTTP API port
EXPOSE 8086
# Admin port
EXPOSE 8083
# Raft port
EXPOSE 8090
# Replication port (protobuf)
EXPOSE 8099

CMD ["/usr/bin/influxdb", "-config=/opt/influxdb/shared/config.toml"]
