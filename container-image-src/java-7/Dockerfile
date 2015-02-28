FROM nordstrom/baseimage-ubuntu:14.04.1
MAINTAINER Emmanuel Gomez "emmanuel.gomez@nordstrom.com"

RUN apt-get update -qy \
 && apt-get install -qy --no-install-recommends --no-install-suggests \
     openjdk-7-jre-headless \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
