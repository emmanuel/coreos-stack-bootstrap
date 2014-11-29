#!/bin/bash

KAFKA_STORED_BROKER_ID=$(cat /kafka/conf/broker_id)
KAFKA_BROKER_ID=${KAFKA_STORED_BROKER_ID:$RANDOM}
echo "$KAFKA_BROKER_ID" > /kafka/conf/broker_id
echo "Starting Kafka broker with ID $KAFKA_BROKER_ID"
echo "broker.id=$KAFKA_BROKER_ID" >> $KAFKA_HOME/config/server.properties
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
