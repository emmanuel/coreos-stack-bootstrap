FROM nordstrom/baseimage-ubuntu-core-1404:latest
MAINTAINER Emmanuel Gomez "emmanuel@gomez.io"

# http://s3.amazonaws.com/influxdb/influxdb_0.8.3_amd64.deb
ADD dist/influxdb_0.8.3_amd64.deb /
ADD conf/config.toml /opt/influxdb/shared/config.toml

RUN mkdir -p /opt/influxdb/shared/data && \
    dpkg -i /influxdb_0.8.3_amd64.deb && \
    rm -rf /opt/influxdb/shared/data && \
    chown -R daemon:daemon /opt/influxdb

USER daemon

# HTTP API port
EXPOSE 8086
# Admin port
EXPOSE 8083
# Raft port
EXPOSE 8090
# Replication port (protobuf)
EXPOSE 8099

CMD ["/usr/bin/influxdb", "-config=/opt/influxdb/shared/config.toml"]
