#!/bin/bash

KAFKA_BROKER_ID=$RANDOM
echo "Starting Kafka broker with ID $KAFKA_BROKER_ID"
echo "broker.id=$KAFKA_BROKER_ID" >> $KAFKA_HOME/config/server.properties
$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties
