#!/bin/bash

KAFKA_REST_SERVER_ID=kafka-rest-${RANDOM}
echo "Starting Kafka REST proxy with ID ${KAFKA_REST_SERVER_ID}"
echo "id=${KAFKA_REST_SERVER_ID}" >> /etc/kafka-rest/kafka-rest.properties
/usr/bin/kafka-rest-start /etc/kafka-rest/kafka-rest.properties
