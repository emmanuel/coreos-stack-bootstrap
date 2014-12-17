#!/bin/sh

# MAX_OPEN_FILES=65535
# MAX_MAP_COUNT=262144
# MAX_LOCKED_MEMORY=

# ulimit -n $MAX_OPEN_FILES
# ulimit -l $MAX_LOCKED_MEMORY
# sysctl -q -w vm.max_map_count=$MAX_MAP_COUNT

# NAME=elasticsearch

# PATH=/bin:/usr/bin:/sbin:/usr/sbin
# LOG_DIR=/var/log/$NAME
# DATA_DIR=/var/lib/$NAME
# WORK_DIR=/tmp/$NAME
# CONF_DIR=/etc/$NAME
# CONF_FILE=$CONF_DIR/elasticsearch.yml
# ES_HOME=/usr/share/$NAME

# ES_USER=elasticsearch
# ES_GROUP=elasticsearch

# export ES_HEAP_SIZE
# export ES_HEAP_NEWSIZE
# export ES_DIRECT_SIZE
# export ES_JAVA_OPTS

# mkdir -p "$LOG_DIR" "$DATA_DIR" "$WORK_DIR" && chown "$ES_USER":"$ES_GROUP" "$LOG_DIR" "$DATA_DIR" "$WORK_DIR"

/usr/share/elasticsearch/bin/elasticsearch \
  --default.config=$CONF_FILE \
  --default.path.home=$ES_HOME \
  --default.path.logs=$LOG_DIR \
  --default.path.data=$DATA_DIR \
  --default.path.work=$WORK_DIR \
  --default.path.conf=$CONF_DIR
