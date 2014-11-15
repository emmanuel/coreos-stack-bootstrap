#!/bin/sh

/opt/logstash-$LOGSTASH_RELEASE/bin/logstash \
  -f /opt/logstash-$LOGSTASH_RELEASE/conf/logstash.conf
