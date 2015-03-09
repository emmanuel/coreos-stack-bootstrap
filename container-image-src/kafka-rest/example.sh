#!/bin/bash

curl -s -XPOST \
  -H"Content-Type: application/.kafka.v1+json, application/vnd.kafka+json, application/json" \
    kafka-rest:8082/topics/test2 \
      -d '{"records":[{"key":"a2V5","value":"Y29uZmx1ZW50"},{"value":"bG9ncw=="}]}'
