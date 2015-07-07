FROM nordstrom/baseimage-alpine:3.2
MAINTAINER Innovation Platform Team "invcldtm@nordstrom.com"

RUN apk --update add \
      python \
      py-pip \
 && pip install --upgrade pip \
 && rm -rf /var/cache/apk/*
